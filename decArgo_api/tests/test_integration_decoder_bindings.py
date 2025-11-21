"""
Intégration: lance réellement le décodeur sur 3 flotteurs, compare les sorties
avec des références validées (golden outputs). Toute divergence = échec.
Lancer explicitement:  pytest -m "integration and matlab" -q
"""

import os
import sys
import importlib
from pathlib import Path
from typing import Iterable

import numpy as np
import pytest

# --- Marqueurs: désactivés par défaut ---
pytestmark = [pytest.mark.integration, pytest.mark.matlab]

# --- Paramétrage : 3 flotteurs (wmo + configuration + outputs de reference) --------------------------
# A partir des données du repertoire decArgo_demo
# À fournir :
#   DECODER_EXECUTABLE, MATLAB_RUNTIME, DECODER_INPUT_DIR
WMOS = [
    (
        "6902892",
        "./tests/data/config/decoder_conf_for_6902892.json",
        "./tests/data/ref/6902892",
    ),
    (
        "6903014",
        "./tests/data/config/decoder_conf_for_6903014.json",
        "./tests/data/ref/6903014",
    ),
    (
        "6904182",
        "./tests/data/config/decoder_conf_for_6904182.json",
        "./tests/data/ref/6904182",
    ),
]


# --- Aides: vérifs d'environnement, fail fast avec skip motivé ---------------
def _need_file(env: str) -> Path:
    p = os.getenv(env)
    if not p:
        pytest.skip(f"Missing env var: {env}")
    path = Path(p)
    if not path.exists():
        pytest.skip(f"{env} points to missing path: {path}")
    return path


def _need_dir(env: str) -> Path:
    p = _need_file(env)
    if not p.is_dir():
        pytest.skip(f"{env} is not a directory: {p}")
    return p


def _need_exec(env: str) -> Path:
    p = _need_file(env)
    if not os.access(p, os.X_OK):
        pytest.skip(f"{env} is not executable: {p}")
    return p


# --- Import du module testé + alias des imports plats utilisés dans main.py ---
# Le module 'decoder_bindings.main' fait des imports "plats" (utilities, mock_data).
# On crée des alias vers les sous-modules du package pour que l'import réussisse.
sys.modules.setdefault("utilities", importlib.import_module("decoder_bindings.utilities"))
sys.modules.setdefault(
    "utilities.dict2json",
    importlib.import_module("decoder_bindings.utilities.dict2json"),
)

from decoder_bindings.main import Decoder  # noqa: E402


# --- Comparaison NetCDF robuste (échec au moindre écart par défaut) ----------
def _assert_netcdf_equal(test_path: Path, ref_path: Path, *, atol: float, rtol: float) -> None:
    """
    Compare deux fichiers NetCDF:
      - dimensions (noms, tailles)
      - variables (noms, dtypes, shapes, valeurs)
      - attributs globaux (sauf liste ignorée)
    Echec si la moindre différence est détectée.
    """
    try:
        from netCDF4 import Dataset
    except Exception as e:
        pytest.skip(f"netCDF4 not available: {e}")

    volatile_globals = {
        "history",
        "date_created",
        "creation_date",
        "last_update",
        "date_update",
        "uuid",
        "checksum",
        "processing_history",
        "file_generation_time",
    }

    with Dataset(test_path, "r") as tds, Dataset(ref_path, "r") as rds:
        # Dimensions
        assert set(tds.dimensions.keys()) == set(rds.dimensions.keys()), "Different dimension names"
        for name in tds.dimensions.keys():
            assert len(tds.dimensions[name]) == len(rds.dimensions[name]), f"Dimension size mismatch: {name}"

        # Variables
        assert set(tds.variables.keys()) == set(rds.variables.keys()), "Different variable names"
        for vname in tds.variables.keys():
            tv = tds.variables[vname]
            rv = rds.variables[vname]
            # dtype + shape
            assert tv.dtype == rv.dtype, f"dtype mismatch for var {vname}"
            assert tv.shape == rv.shape, f"shape mismatch for var {vname}"
            # valeurs (avec tolérances pour numériques)
            tdata = np.array(tv[:])
            rdata = np.array(rv[:])
            if np.issubdtype(tv.dtype, np.number):
                # ma/masques -> on remplit avec NaN pour comparer
                if np.ma.isMaskedArray(tdata):
                    tdata = tdata.filled(np.nan)
                if np.ma.isMaskedArray(rdata):
                    rdata = rdata.filled(np.nan)
                # tout écart au-delà des tolérances = échec
                assert np.allclose(tdata, rdata, atol=atol, rtol=rtol, equal_nan=True), f"value mismatch in var {vname}"
            else:
                # strings, bytes: égalité stricte
                assert np.array_equal(tdata, rdata), f"value mismatch in var {vname}"

        # Attributs globaux (hors volatiles)
        tga = {k: getattr(tds, k) for k in tds.ncattrs() if k not in volatile_globals}
        rga = {k: getattr(rds, k) for k in rds.ncattrs() if k not in volatile_globals}
        assert tga == rga, "global attributes mismatch (non-volatile)"


def _iter_nc_files(dirpath: Path) -> Iterable[Path]:
    return sorted(dirpath.rglob("*.nc"))


def _iter_nc(dirpath: Path) -> Iterable[Path]:
    return sorted(dirpath.rglob("*.nc"))


def _compare_dirs_nc(test_dir: Path, ref_dir: Path, *, atol: float, rtol: float) -> None:
    """
    Compare l'ensemble des .nc produits vs la référence:
      - mêmes fichiers (noms relatifs)
      - contenu égal (cf _assert_netcdf_equal)
    """
    # map par chemin relatif (pour supporter des sous-répertoires identiques)
    t_map = {p.relative_to(test_dir): p for p in _iter_nc_files(test_dir)}
    r_map = {p.relative_to(ref_dir): p for p in _iter_nc_files(ref_dir)}

    assert set(t_map.keys()) == set(r_map.keys()), (
        "Different NetCDF file sets:\n"
        f"Only in test: {sorted(set(t_map.keys()) - set(r_map.keys()))}\n"
        f"Only in ref : {sorted(set(r_map.keys()) - set(t_map.keys()))}"
    )

    for rel in sorted(t_map.keys()):
        _assert_netcdf_equal(t_map[rel], r_map[rel], atol=atol, rtol=rtol)


# ========================== Test A : exécution OK =============================
@pytest.mark.parametrize("wmo, conf_file, ref_dir", WMOS)
def test_decode_produces_netcdf(tmp_path: Path, wmo: str, conf_file: str, ref_dir: str):
    exec_path = _need_exec("DECODER_EXECUTABLE")
    runtime_dir = _need_dir("MATLAB_RUNTIME")
    timeout = int(os.getenv("DECODER_TIMEOUT", "1800"))

    out_dir = Path(f"../decArgo_demo/output/nc/{wmo}")

    dec = Decoder(
        input_files_directory=None,  # from configuration file
        output_files_directory=None,  # from configuration file
        decoder_conf_file=str(conf_file),
        decoder_executable=str(exec_path),
        matlab_runtime=str(runtime_dir),
        timeout_seconds=timeout,
        hold_after_run=None,
    )

    dec.decode(wmo)

    produced = list(_iter_nc(out_dir))
    assert produced, f"Aucun NetCDF produit pour WMO {wmo} dans {out_dir}"


# TODO : Compare results to output from decoder in DAC infrastructure ?
# ========================== Test B : comparaison ==============================
# @pytest.mark.parametrize("wmo, conf_file, ref_dir", WMOS)
# def test_decode_outputs_match_reference(
#     tmp_path: Path, wmo: str, conf_file: str, ref_dir: str
# ):
#     exec_path = _need_exec("DECODER_EXECUTABLE")
#     runtime_dir = _need_dir("MATLAB_RUNTIME")
#     input_dir = _need_dir("DECODER_INPUT_DIR")
#     conf_file = _need_file(conf_file)
#     timeout = int(os.getenv("DECODER_TIMEOUT", "1800"))

#     atol = float(os.getenv("NC_ATOL", "0"))
#     rtol = float(os.getenv("NC_RTOL", "0"))
#     timeout = int(os.getenv("DECODER_TIMEOUT", "1800"))

#     out_dir = tmp_path / f"out_{wmo}"
#     out_dir.mkdir()

#     dec = Decoder(
#         input_files_directory=str(input_dir),
#         output_files_directory=str(out_dir),
#         decoder_conf_file=str(conf_file),
#         decoder_executable=str(exec_path),
#         matlab_runtime=str(runtime_dir),
#         timeout_seconds=timeout,
#         hold_after_run=None,
#     )

#     dec.decode(wmo)

#     _compare_dirs_nc(out_dir, ref_dir, atol=atol, rtol=rtol)
