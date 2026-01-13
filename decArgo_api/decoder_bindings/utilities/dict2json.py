import os
import json
from pathlib import Path


def save_info_meta_conf(
    config_dir: str,
    float_info_dir: str,
    float_meta_dir: str,
    info: dict,
    meta: dict,
    decoder_conf: dict,
):
    """
    Save info and meta dictionaries into specified directory structure.
    Extracts WMO and PTT from the info dictionary.

    Parameters:
        config_dir (str): Base configuration directory for all floats.
        float_info_dir (str): Directory to save float info JSON files.
        float_meta_dir (str): Directory to save float meta JSON files.
        info (dict): Info dictionary containing WMO and PTT keys.
        meta (dict): Meta dictionary to save.
        decoder_conf (dict): Decoder configuration dictionary to save.

    Returns:
        dict: Dictionary containing paths to created files.

    Raises:
        ValueError: If WMO or PTT keys are missing from info dictionary.
    """

    # Extract WMO and PTT from info dictionary
    wmo = info.get("WMO")
    ptt = info.get("PTT")

    if not wmo:
        raise ValueError("Info dictionary must contain 'WMO' key")
    if not ptt:
        raise ValueError("Info dictionary must contain 'PTT' key")

    # Convert to strings and clean up
    wmo = str(wmo).strip()
    ptt = str(ptt).strip()

    directories = {
        "json_float_info": Path(float_info_dir),
        "json_float_meta": Path(float_meta_dir),
        "config": Path(config_dir),
    }
    # Ensure directories exist
    for dir_path in directories.values():
        dir_path.mkdir(parents=True, exist_ok=True)

    # Generate file paths
    info_file = directories["json_float_info"] / f"{wmo}_{ptt}_info.json"
    meta_file = directories["json_float_meta"] / f"{wmo}_meta.json"
    conf_file = directories["config"] / "decoder_conf.json"

    try:
        # Write info file
        with open(info_file, "w", encoding="utf-8") as f:
            json.dump(info, f, indent=4, ensure_ascii=False)

        # Write meta file
        with open(meta_file, "w", encoding="utf-8") as f:
            json.dump(meta, f, indent=4, ensure_ascii=False)

        # Write decoder configuration file
        with open(conf_file, "w", encoding="utf-8") as f:
            json.dump(decoder_conf, f, indent=4, ensure_ascii=False)

        print(f"Successfully saved info , meta and conf files for WMO {wmo}, PTT {ptt}")

        return {
            "info_file": str(info_file.absolute()),
            "meta_file": str(meta_file.absolute()),
            "conf_file": str(conf_file.absolute()),
        }

    except Exception as e:
        raise IOError(f"Failed to save configuration files: {e}")
