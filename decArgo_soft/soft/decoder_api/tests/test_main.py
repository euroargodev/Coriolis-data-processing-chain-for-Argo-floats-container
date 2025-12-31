"""Tests for the main bindings code."""

from pathlib import Path
import pytest
from decoder_bindings.main import DecoderConfiguration, EmptyInputDirectoryError, Decoder


def test_decoder_configuration_with_valid_directories(tmp_path: Path):
    """Test that the decoder config fires up correctly."""
    input_path = tmp_path / "input"
    output_path = tmp_path / "output"

    input_path.mkdir()
    output_path.mkdir()

    (input_path / "dummy_file.txt").write_text("Hello")

    decoder_config = DecoderConfiguration(input_files_directory=input_path, output_files_directory=output_path)


    assert decoder_config.input_files_directory == input_path
    assert decoder_config.output_files_directory == output_path

def test_decoder_with_empty_input_directory(tmp_path: Path):
    """Test that the appopriate error is raised when the input directory is empty."""
    input_path = tmp_path / "input"
    output_path = tmp_path / "output"

    input_path.mkdir()
    output_path.mkdir()

    with pytest.raises(EmptyInputDirectoryError):
        DecoderConfiguration(
            input_files_directory=input_path, output_files_directory=output_path)


def test_decoder_with_invalid_directories(tmp_path: Path):
    """Test that the appropriate error is raised when various directories are empty."""

    input_path = tmp_path / "input"
    output_path = tmp_path / "output"



    with pytest.raises(ValueError) as exc:
        DecoderConfiguration(
                input_files_directory=input_path, output_files_directory=output_path)
    assert "is not a valid input directory" in str(exc.value)

    # Make and populate the input directory, so the next validation can be tested (output).
    input_path.mkdir()
    (input_path / "test.txt").write_text("test")

    with pytest.raises(ValueError) as exc:
        DecoderConfiguration(
                input_files_directory=input_path, output_files_directory=output_path)
    assert "is not a valid output directory" in str(exc.value)

    # Then make the output directory, so the next validation can be tested (config).
    output_path.mkdir()

def test_decoder_initialisation(tmp_path: Path):
    """Test that the main Decoder class can be initialised."""
    input_path = tmp_path / "input"
    output_path = tmp_path / "output"

    input_path.mkdir()
    output_path.mkdir()

    (input_path / "test.txt").write_text("test")

    decoder_instance = Decoder(input_files_directory=input_path,
                               output_files_directory=output_path)
    
    assert isinstance(decoder_instance, Decoder)
    assert isinstance(decoder_instance.config, DecoderConfiguration)
    assert(isinstance(decoder_instance.config.input_files_directory, Path))
    assert(isinstance(decoder_instance.config.output_files_directory, Path))


def test_subprocess_call(mocker, tmp_path: Path):
    """Test the subprocess call fires correctly."""
    input_path = tmp_path / "input"
    output_path = tmp_path / "output"

    input_path.mkdir()
    output_path.mkdir()

    (input_path / "test.txt").write_text("test")

    decoder_instance = Decoder(input_files_directory=input_path,
                               output_files_directory=output_path)
    subprocess_call = mocker.patch("decoder_bindings.main.subprocess.run")
    decoder_instance.decode("123")


    subprocess_call.assert_called_once()
