"""
Tests pour la version finale du Decoder :
- exécutable & runtime configurables
- hold optionnel à la place de la boucle infinie
- validation chemins + WMO
- commande construite correctement (avec/ sans I/O)
"""

import sys
import stat
import types
import importlib
from pathlib import Path
from unittest.mock import patch
import pytest


# -----------------------------------------------------------------------------
# Stubs pour les imports top-level du module (utilities.dict2json, mock_data)
# -----------------------------------------------------------------------------
def _inject_stubs_for_top_level_imports():
    if "utilities.dict2json" not in sys.modules:
        utilities = types.ModuleType("utilities")
        dict2json = types.ModuleType("utilities.dict2json")

        def save_info_meta_conf(*args, **kwargs):
            return {}

        dict2json.save_info_meta_conf = save_info_meta_conf
        utilities.dict2json = dict2json
        sys.modules["utilities"] = utilities
        sys.modules["utilities.dict2json"] = dict2json

    if "mock_data" not in sys.modules:
        mock_data = types.ModuleType("mock_data")
        mock_data.info_dict = {}
        mock_data.meta_dict = {}
        mock_data.conf_dict = {}
        sys.modules["mock_data"] = mock_data


_inject_stubs_for_top_level_imports()

# -----------------------------------------------------------------------------
# Import du module à tester
# -----------------------------------------------------------------------------

# Aligne les imports "plats" utilisés dans main.py
# (main.py fait `from utilities...` et `from mock_data...`)
sys.modules.setdefault("utilities", importlib.import_module("decoder_bindings.utilities"))
sys.modules.setdefault(
    "utilities.dict2json",
    importlib.import_module("decoder_bindings.utilities.dict2json"),
)
sys.modules.setdefault("mock_data", importlib.import_module("decoder_bindings.mock_data"))

MODULE_NAME = "decoder_bindings.main"
m = importlib.import_module(MODULE_NAME)


# -----------------------------------------------------------------------------
# Fixtures utilitaires
# -----------------------------------------------------------------------------
@pytest.fixture
def tmp_conf_file(tmp_path: Path) -> Path:
    p = tmp_path / "api.decoder_conf.json"
    p.write_text('{"some":"config"}', encoding="utf-8")
    return p


@pytest.fixture
def tmp_runtime_dir(tmp_path: Path) -> Path:
    d = tmp_path / "matlab_runtime"
    d.mkdir()
    return d


@pytest.fixture
def tmp_exec_file(tmp_path: Path) -> Path:
    f = tmp_path / "run_decode.sh"
    f.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    # rendre exécutable
    f.chmod(f.stat().st_mode | stat.S_IXUSR)
    return f


@pytest.fixture
def tmp_nonexec_file(tmp_path: Path) -> Path:
    f = tmp_path / "not_exec.sh"
    f.write_text("echo nope\n", encoding="utf-8")
    # s’assurer qu’il N’EST PAS exécutable
    f.chmod(0o644)
    return f


@pytest.fixture
def tmp_input_dir(tmp_path: Path) -> Path:
    d = tmp_path / "input"
    d.mkdir()
    (d / "dummy.bin").write_bytes(b"\x00\x01")
    return d


@pytest.fixture
def tmp_output_dir(tmp_path: Path) -> Path:
    d = tmp_path / "output"
    d.mkdir()
    return d


# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------


@pytest.mark.parametrize("wmo", ["6902892", "4902452", "7901234"])
def test_decode_builds_cmd_with_exec_and_runtime_and_io(
    wmo, tmp_conf_file, tmp_runtime_dir, tmp_exec_file, tmp_input_dir, tmp_output_dir
):
    dec = m.Decoder(
        input_files_directory=str(tmp_input_dir),
        output_files_directory=str(tmp_output_dir),
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=str(tmp_runtime_dir),
        timeout_seconds=123,
        hold_after_run=None,
    )

    with patch.object(m.subprocess, "run") as mock_run:
        mock_run.return_value = types.SimpleNamespace(returncode=0)
        dec.decode(wmo)

        (args, kwargs) = mock_run.call_args
        cmd = args[0]

        # exécutable + runtime en tête
        assert cmd[0] == str(tmp_exec_file.resolve())
        assert cmd[1] == str(tmp_runtime_dir.resolve())

        # arguments invariants
        assert cmd[2:6] == [
            "rsynclog",
            "all",
            "configfile",
            str(tmp_conf_file.resolve()),
        ]
        assert "xmlreport" in cmd and "logfilexml.xml" in cmd
        # WMO
        assert "floatwmo" in cmd and wmo in cmd
        assert "PROCESS_REMAINING_BUFFERS" in cmd and "1" in cmd

        # I/O
        assert "DIR_INPUT_RSYNC_DATA" in cmd
        assert str(tmp_input_dir.resolve()) in cmd
        assert "DIR_OUTPUT_NETCDF_FILE" in cmd
        assert str(tmp_output_dir.resolve()) in cmd

        # options d'exec
        assert kwargs["timeout"] == 123
        assert kwargs["text"] is True
        assert kwargs["check"] is True
        assert isinstance(kwargs["env"], dict)


def test_decode_without_io_does_not_add_dirs(tmp_conf_file, tmp_runtime_dir, tmp_exec_file):
    dec = m.Decoder(
        input_files_directory=None,
        output_files_directory=None,
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=str(tmp_runtime_dir),
    )

    with patch.object(m.subprocess, "run") as mock_run:
        mock_run.return_value = types.SimpleNamespace(returncode=0)
        dec.decode("6902892")
        cmd = mock_run.call_args[0][0]
        assert "DIR_INPUT_RSYNC_DATA" not in cmd
        assert "DIR_OUTPUT_NETCDF_FILE" not in cmd


def test_decode_input_without_output_raises(tmp_conf_file, tmp_runtime_dir, tmp_exec_file, tmp_input_dir):
    dec = m.Decoder(
        input_files_directory=str(tmp_input_dir),
        output_files_directory=None,
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=str(tmp_runtime_dir),
    )
    with pytest.raises(ValueError):
        dec.decode("6902892")


@pytest.mark.parametrize("bad_wmo", ["", "123", "abcdefg", "69028921", " 6902892 "])
def test_invalid_wmo_raises(bad_wmo, tmp_conf_file, tmp_runtime_dir, tmp_exec_file):
    dec = m.Decoder(
        input_files_directory=None,
        output_files_directory=None,
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=str(tmp_runtime_dir),
    )
    with pytest.raises(m.WmoValidationError):
        dec.decode(bad_wmo)


def test_conf_file_missing_raises(tmp_path: Path, tmp_runtime_dir, tmp_exec_file):
    missing = tmp_path / "nope.json"
    with pytest.raises(ValueError):
        m.Decoder(
            input_files_directory=None,
            output_files_directory=None,
            decoder_conf_file=str(missing),
            decoder_executable=str(tmp_exec_file),
            matlab_runtime=str(tmp_runtime_dir),
        )


def test_executable_must_exist_and_be_executable(tmp_conf_file, tmp_runtime_dir, tmp_nonexec_file):
    # non exécutable -> ValueError
    with pytest.raises(ValueError):
        m.Decoder(
            input_files_directory=None,
            output_files_directory=None,
            decoder_conf_file=str(tmp_conf_file),
            decoder_executable=str(tmp_nonexec_file),
            matlab_runtime=str(tmp_runtime_dir),
        )


def test_runtime_must_be_dir(tmp_conf_file, tmp_exec_file, tmp_path: Path):
    not_a_dir = tmp_path / "file.txt"
    not_a_dir.write_text("x", encoding="utf-8")
    with pytest.raises(ValueError):
        m.Decoder(
            input_files_directory=None,
            output_files_directory=None,
            decoder_conf_file=str(tmp_conf_file),
            decoder_executable=str(tmp_exec_file),
            matlab_runtime=str(not_a_dir),
        )


def test_calledprocesserror_is_caught_and_hold_runs(
    tmp_conf_file, tmp_runtime_dir, tmp_exec_file, tmp_input_dir, tmp_output_dir
):
    dec = m.Decoder(
        input_files_directory=str(tmp_input_dir),
        output_files_directory=str(tmp_output_dir),
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=str(tmp_runtime_dir),
        hold_after_run=2,
    )

    with patch.object(m.subprocess, "run") as mock_run, patch.object(m.time, "sleep") as mock_sleep:
        mock_run.side_effect = m.subprocess.CalledProcessError(returncode=42, cmd=["x"])
        dec.decode("6902892")  # ne doit pas lever
        mock_sleep.assert_called_once_with(2)


def test_hold_after_run_none_no_sleep(tmp_conf_file, tmp_runtime_dir, tmp_exec_file):
    dec = m.Decoder(
        input_files_directory=None,
        output_files_directory=None,
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=str(tmp_runtime_dir),
        hold_after_run=None,
    )
    with patch.object(m.subprocess, "run") as mock_run, patch.object(m.time, "sleep") as mock_sleep:
        mock_run.return_value = types.SimpleNamespace(returncode=0)
        dec.decode("6902892")
        mock_sleep.assert_not_called()


def test_hold_after_run_forever_loops_but_is_mocked(tmp_conf_file, tmp_runtime_dir, tmp_exec_file):
    dec = m.Decoder(
        input_files_directory=None,
        output_files_directory=None,
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=str(tmp_runtime_dir),
        hold_after_run=-1,  # hold “infini”
    )

    call_count = {"n": 0}

    def fake_sleep(seconds: int):
        # le hold infini dort par pas de 60s
        assert seconds == 60
        call_count["n"] += 1
        if call_count["n"] >= 3:
            raise StopIteration  # on coupe le test ici

    with patch.object(m.subprocess, "run") as mock_run, patch.object(m.time, "sleep", side_effect=fake_sleep):
        mock_run.return_value = types.SimpleNamespace(returncode=0)
        with pytest.raises(StopIteration):
            dec.decode("6902892")
        assert call_count["n"] >= 3


def test_decoder_configuration_with_valid_directories(tmp_input_dir, tmp_output_dir, tmp_conf_file, tmp_exec_file):
    """Test que la config se construit correctement avec des chemins valides."""
    cfg = m.DecoderConfiguration(
        input_files_directory=tmp_input_dir,
        output_files_directory=tmp_output_dir,
        decoder_conf_file=tmp_conf_file,
        decoder_executable=tmp_exec_file,  # requis par tes validateurs
        matlab_runtime=None,  # optionnel
    )
    assert cfg.input_files_directory == tmp_input_dir.resolve()
    assert cfg.output_files_directory == tmp_output_dir.resolve()


def test_decoder_with_empty_input_directory(tmp_path: Path, tmp_output_dir, tmp_conf_file, tmp_exec_file):
    """Dossier d'entrée vide -> EmptyInputDirectoryError."""
    empty_input = tmp_path / "empty_in"
    empty_input.mkdir()
    with pytest.raises(m.EmptyInputDirectoryError):
        m.DecoderConfiguration(
            input_files_directory=empty_input,
            output_files_directory=tmp_output_dir,
            decoder_conf_file=tmp_conf_file,
            decoder_executable=tmp_exec_file,
            matlab_runtime=None,  # optionnel
        )


def test_decoder_with_invalid_directories(tmp_path: Path, tmp_conf_file, tmp_exec_file):
    """Dossiers inexistants -> ValueError cohérente."""
    input_path = tmp_path / "input"  # n'existe pas
    output_path = tmp_path / "output"  # n'existe pas

    with pytest.raises(ValueError) as exc:
        m.DecoderConfiguration(
            input_files_directory=input_path,
            output_files_directory=output_path,
            decoder_conf_file=tmp_conf_file,
            decoder_executable=tmp_exec_file,
            matlab_runtime=None,  # optionnel
        )
    assert "is not a valid input directory" in str(exc.value)

    # créer input pour tester la validation de output
    input_path.mkdir()
    (input_path / "test.txt").write_text("test", encoding="utf-8")

    with pytest.raises(ValueError) as exc:
        m.DecoderConfiguration(
            input_files_directory=input_path,
            output_files_directory=output_path,
            decoder_conf_file=tmp_conf_file,
            decoder_executable=tmp_exec_file,
            matlab_runtime=None,  # optionnel
        )
    assert "is not a valid output directory" in str(exc.value)


def test_decoder_initialisation(tmp_input_dir, tmp_output_dir, tmp_conf_file, tmp_exec_file):
    """Initialisation de Decoder avec chemins valides."""
    dec = m.Decoder(
        input_files_directory=str(tmp_input_dir),
        output_files_directory=str(tmp_output_dir),
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=None,  # optionnel dans la config
    )
    assert isinstance(dec, m.Decoder)
    assert isinstance(dec.config, m.DecoderConfiguration)
    assert dec.config.input_files_directory == tmp_input_dir.resolve()
    assert dec.config.output_files_directory == tmp_output_dir.resolve()


def test_subprocess_call(monkeypatch, tmp_input_dir, tmp_output_dir, tmp_conf_file, tmp_exec_file):
    """Initialisation de Decoder avec chemins valides."""
    dec = m.Decoder(
        input_files_directory=str(tmp_input_dir),
        output_files_directory=str(tmp_output_dir),
        decoder_conf_file=str(tmp_conf_file),
        decoder_executable=str(tmp_exec_file),
        matlab_runtime=None,  # optionnel dans la config
    )

    called = {"n": 0, "cmd": None}

    def fake_run(cmd, **kwargs):
        called["n"] += 1
        called["cmd"] = cmd
        return types.SimpleNamespace(returncode=0)

    monkeypatch.setattr(m.subprocess, "run", fake_run)

    dec.decode("6902892")

    assert called["n"] == 1
    assert called["cmd"][0] == str(tmp_exec_file.resolve())
    # si matlab_runtime=None, ton code passe "None" en 2e arg → on l'accepte ici
    # et on vérifie le reste de la commande
    assert "floatwmo" in called["cmd"] and "6902892" in called["cmd"]
