import os
import yaml

class NoAliasDumper(yaml.SafeDumper):
    def ignore_aliases(self, data):
        """
        Ensures that aliases are not used in the dumped YAML.
        """
        return True

def str_presenter(dumper, data):
    """
    Custom string presenter that uses '|' for multiline strings.
    
    :param dumper: The YAML dumper.
    :param data: The string data to present.
    :return: The presented string data.
    """
    if isinstance(data, str) and '\n' in data:
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
    return dumper.represent_scalar('tag:yaml.org,2002:str', data)

def dict_representer(dumper, data):
    """
    Custom dictionary presenter.
    
    :param dumper: The YAML dumper.
    :param data: The dictionary data to present.
    :return: The presented dictionary data.
    """
    return dumper.represent_dict(data.items())

# Register custom presenters for string and dictionary types.
NoAliasDumper.add_representer(str, str_presenter)
NoAliasDumper.add_representer(dict, dict_representer)

def apply_patch(target: dict, patch: dict) -> None:
    """
    Recursively applies patches to the target dictionary.

    :param target: Dictionary to apply patches to.
    :param patch: Dictionary containing the patches.
    """
    for key, value in patch.items():
        if key in target and isinstance(value, dict):
            apply_patch(target[key], value)
        else:
            target[key] = value

def remove_unnecessary_keys(data: dict, keys_to_skip: list) -> None:
    """
    Removes unnecessary keys from the data dictionary based on a list of keys to skip.

    :param data: Dictionary to remove keys from.
    :param keys_to_skip: List of keys to skip.
    """
    for skip_key in keys_to_skip:
        if skip_key in data:
            del data[skip_key]

def merge_dicts(dict1, dict2):
    """
    Recursively merges two dictionaries.

    :param dict1: First dictionary.
    :param dict2: Second dictionary.
    :return: Merged dictionary.
    """
    for key, value in dict2.items():
        if key in dict1:
            if isinstance(dict1[key], dict) and isinstance(value, dict):
                merge_dicts(dict1[key], value)
            elif isinstance(dict1[key], list) and isinstance(value, list):
                dict1[key].extend(value)
            else:
                dict1[key] = value
        else:
            dict1[key] = value
    return dict1

def merge_yaml_files(file_paths: list, configuration: dict) -> dict:
    """
    Merges multiple YAML files into a single dictionary, applying configurations.

    :param file_paths: List of file paths to YAML files.
    :param configuration: Dictionary containing configuration for skipping and overriding keys.
    :return: Dictionary containing merged content.
    """
    merged_data = {}
    
    for file_path in file_paths:
        with open(file_path, encoding="utf-8") as f:
            file_yaml = yaml.full_load(f)
            if not file_yaml:
                print(f"The content of the file is not a valid YAML '{file_path}'.")
                continue

            merged_data = merge_dicts(merged_data, file_yaml)
    
    # Remove unnecessary keys
    if "skip" in configuration:
        remove_unnecessary_keys(merged_data["rules"], configuration["skip"])

    # Apply overrides to fields
    if "override" in configuration:
        apply_patch(merged_data["rules"], configuration["override"])
    
    return merged_data

def get_rules_files(paths: list) -> list:
    """
    Retrieves the list of YAML rule files from the given directories.

    :param paths: List of paths to the directories containing the rule files.
    :return: List of YAML file paths.
    """
    yaml_files = []
    for path in paths:
        if not os.path.exists(path):
            raise ValueError(f"Rules folder path '{path}' does not exist.")

        files = os.listdir(path)

        for file in files:
            if file.lower().endswith((".yml", ".yaml")):
                full_path = os.path.join(path, file)
                yaml_files.append(full_path)

    if not yaml_files:
        raise ValueError("No YAML files found in the specified rules folders.")

    return yaml_files

def load_configuration(path: str) -> dict:
    """
    Loads the configuration file.

    :param path: Path to the configuration file.
    :return: Dictionary containing the configuration rules.
    """
    if not os.path.exists(path):
        raise ValueError(f"Configuration file path '{path}' does not exist.")

    try:
        with open(path, encoding="utf-8") as f:
            config = yaml.full_load(f)
    except yaml.YAMLError as e:
        raise ValueError(f"Error reading configuration file '{path}': {e}")

    return config.get("rules", {})

def load_template(path: str) -> str:
    """
    Loads the content of the template file.

    :param path: Path to the template file.
    :return: String containing the content of the template file.
    """
    if not os.path.exists(path):
        raise ValueError(f"Template file path '{path}' does not exist.")

    with open(path, encoding="utf-8") as f:
        return f.read()

def main():
    """
    Main function to load environment variables, retrieve rule files, and merge them according to the configuration.
    """
    RULESET_NAME = os.getenv("RULESET_NAME", None)
    RULESET_VERSION = os.getenv("RULESET_VERSION", None)
    RULESET_FILE_NAME = os.getenv("RULESET_FILE_NAME", None)
    RULES_FOLDERS = os.getenv("RULES_FOLDERS", None)
    CONFIG_FILE = os.getenv("CONFIG_FILE", None)
    TEMPLATE_FILE = os.getenv("TEMPLATE_FILE", None)

    if not RULES_FOLDERS:
        raise ValueError("RULES_FOLDERS environment variable is required.")
    
    if not RULESET_FILE_NAME:
        raise ValueError("RULESET_FILE_NAME environment variable is required.")

    # Split the RULES_FOLDERS by commas and remove any leading/trailing whitespace
    rules_folders = [folder.strip() for folder in RULES_FOLDERS.split(",")]
    yaml_files = get_rules_files(rules_folders)
    yaml_files.sort()

    configuration = {}
    if CONFIG_FILE:
        configuration = load_configuration(CONFIG_FILE)

    merged_data = merge_yaml_files(yaml_files, configuration)

    # Dump the merged data to a YAML string
    output = yaml.dump(merged_data,
                       Dumper=NoAliasDumper,
                       indent=4,
                       sort_keys=False)
    
    # Prepend the ruleset info and the template content if present
    ruleset_info = ""
    if RULESET_NAME and RULESET_VERSION:
        RULESET_NAME = RULESET_NAME.strip()
        RULESET_VERSION = RULESET_VERSION.strip()
        ruleset_info = "#\tRuleset name: %s\n#\tRuleset version: %s\n\n" % (RULESET_NAME, RULESET_VERSION)

    template_content = ""
    if TEMPLATE_FILE:
        template_content = load_template(TEMPLATE_FILE) + "\n"

    output = ruleset_info + template_content + output if template_content else output

    # Write the output YAML to the specified file
    with open(RULESET_FILE_NAME, "w", encoding="utf-8") as f:
        f.write(output)

if __name__ == "__main__":
    main()