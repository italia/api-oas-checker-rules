#!/usr/bin/env python

import argparse
import yaml
import os
import markdown
from lxml.html.clean import clean_html

def get_doc_filename(file_path):
    """Generate a filename for the output document based on the input file path."""
    base_name = os.path.basename(file_path)
    name, _ = os.path.splitext(base_name)
    return f"{name}.html"

def auto_link_rfc(description):
    """Automatically link RFC references in the description."""
    # Example implementation (you might need to adjust this based on your specific needs)
    return description.replace('RFC', '<a href="https://tools.ietf.org/html/RFC">RFC</a>')

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Generate documentation from a ruleset file.")
    parser.add_argument('-f', '--file', required=True, help='The ruleset file used for generating the documentation.')
    parser.add_argument('-o', '--out', required=True, help='The ruleset documentation destination folder.')
    return parser.parse_args()

def read_ruleset(file_path):
    """Read and parse the ruleset YAML file."""
    with open(file_path, 'r', encoding='utf8') as f:
        name_line, version_line = f.readline(), f.readline()
        name_tag, version_tag = "Ruleset name:", "Ruleset version:"
        name = name_line[name_line.index(name_tag) + len(name_tag):].strip()
        version = version_line[version_line.index(version_tag) + len(version_tag):].strip()
        content = f.read()
    return name, version, yaml.safe_load(content)

def generate_markdown(rules, title):
    """Generate markdown content from rules."""
    rules_md = [f"# {title}"]
    for key, value in rules.items():
        if value is False:
            continue
        if 'description' not in value:
            raise ValueError(f"Rule {key} doesn't have a description. Rule description is a required field.")
        description = auto_link_rfc(value['description'])
        rules_md.append(f"## {key}\n\n{description}")
    return "\n\n".join(rules_md)

def convert_markdown_to_html(markdown_content):
    """Convert markdown content to sanitized HTML."""
    raw_html = markdown.markdown(markdown_content)
    return clean_html(raw_html)

def read_bootstrap_css():
    """Read Bootstrap CSS content."""
    bootstrap_css_path = "bootstrap-italia.min.css"
    with open(bootstrap_css_path, 'r', encoding='utf8') as f:
        return f.read()

def generate_html_document(template_path, title, rules_html, bootstrap_css):
    """Generate the final HTML document using a template."""
    with open(template_path, 'r', encoding='utf8') as f:
        template = f.read()
    return template.format(title=title, rules_html=rules_html, bootstrap_css=bootstrap_css)

def write_html_to_file(file_path, html_content):
    """Write the HTML content to the specified file."""
    with open(file_path, 'w', encoding='utf8') as f:
        f.write(html_content)

def main():
    # Parse command line arguments
    args = parse_arguments()
    
    # Read and parse the ruleset file
    name, version, doc = read_ruleset(args.file)
    title = "%s (v%s)" % (name, version)
    
    # Generate markdown content from the rules
    markdown_content = generate_markdown(doc['rules'], title)
    
    # Convert markdown content to sanitized HTML
    rules_html = convert_markdown_to_html(markdown_content)
    
    # Read Bootstrap CSS content
    bootstrap_css = read_bootstrap_css()
    
    # Generate the final HTML document using a template
    template_path = 'template.html'
    html_content = generate_html_document(template_path, title, rules_html, bootstrap_css)
    
    # Determine the output filename and write the HTML content to the file
    doc_filename = get_doc_filename(args.file)
    out_path = args.out
    file_path = os.path.join(out_path, doc_filename)
    write_html_to_file(file_path, html_content)
    print("Documentation for %s saved as %s." % (title, file_path))

if __name__ == "__main__":
    main()