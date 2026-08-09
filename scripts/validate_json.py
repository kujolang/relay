#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path


def fail(path, message):
    raise ValueError(f"{path}: {message}")


def load_schema(schema, base):
    if "$ref" not in schema:
        return schema, base
    reference = schema["$ref"]
    if reference.startswith("http:") or reference.startswith("https:"):
        fail("$ref", "remote references are not supported")
    target = (base / reference).resolve()
    return json.loads(target.read_text()), target.parent


def type_matches(value, expected):
    if expected == "null":
        return value is None
    if expected == "boolean":
        return isinstance(value, bool)
    if expected == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if expected == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if expected == "string":
        return isinstance(value, str)
    if expected == "array":
        return isinstance(value, list)
    if expected == "object":
        return isinstance(value, dict)
    return True


def validate(value, schema, base, path="$", root_schema=None, root_base=None):
    if root_schema is None:
        root_schema, root_base = schema, base
    if "$ref" in schema:
        reference = schema["$ref"]
        if reference.startswith("#"):
            target = root_schema
            for part in reference[2:].split("/") if reference.startswith("#/") else []:
                target = target[part.replace("~1", "/").replace("~0", "~")]
            return validate(value, target, root_base, path, root_schema, root_base)
        resolved, resolved_base = load_schema(schema, base)
        return validate(value, resolved, resolved_base, path, resolved, resolved_base)
    for item in schema.get("allOf", []):
        validate(value, item, base, path, root_schema, root_base)
    if "const" in schema and value != schema["const"]:
        fail(path, f"expected constant {schema['const']!r}")
    if "enum" in schema and value not in schema["enum"]:
        fail(path, f"value {value!r} is not in enum")
    expected = schema.get("type")
    if expected:
        choices = expected if isinstance(expected, list) else [expected]
        if not any(type_matches(value, choice) for choice in choices):
            fail(path, f"expected type {expected!r}, got {type(value).__name__}")
    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            fail(path, "string is shorter than minLength")
        if "maxLength" in schema and len(value) > schema["maxLength"]:
            fail(path, "string exceeds maxLength")
        if "pattern" in schema and re.search(schema["pattern"], value) is None:
            fail(path, f"string does not match {schema['pattern']!r}")
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        if "minimum" in schema and value < schema["minimum"]:
            fail(path, "number is below minimum")
        if "maximum" in schema and value > schema["maximum"]:
            fail(path, "number exceeds maximum")
    if isinstance(value, list):
        if len(value) < schema.get("minItems", 0):
            fail(path, "array is shorter than minItems")
        if "maxItems" in schema and len(value) > schema["maxItems"]:
            fail(path, "array exceeds maxItems")
        if schema.get("uniqueItems") and len({json.dumps(item, sort_keys=True) for item in value}) != len(value):
            fail(path, "array items are not unique")
        if "items" in schema:
            for index, item in enumerate(value):
                validate(item, schema["items"], base, f"{path}[{index}]", root_schema, root_base)
    if isinstance(value, dict):
        for key in schema.get("required", []):
            if key not in value:
                fail(path, f"missing required property {key!r}")
        if "maxProperties" in schema and len(value) > schema["maxProperties"]:
            fail(path, "object exceeds maxProperties")
        properties = schema.get("properties", {})
        patterns = schema.get("patternProperties", {})
        for key, item in value.items():
            if key in properties:
                validate(item, properties[key], base, f"{path}.{key}", root_schema, root_base)
                continue
            matched = False
            for pattern, child_schema in patterns.items():
                if re.search(pattern, key):
                    validate(item, child_schema, base, f"{path}.{key}", root_schema, root_base)
                    matched = True
            if not matched and schema.get("additionalProperties") is False:
                fail(path, f"unexpected property {key!r}")
            if not matched and isinstance(schema.get("additionalProperties"), dict):
                validate(item, schema["additionalProperties"], base, f"{path}.{key}", root_schema, root_base)


def main():
    if len(sys.argv) != 3:
        print("usage: validate_json.py <schema.json> <instance.json>", file=sys.stderr)
        return 2
    schema_path = Path(sys.argv[1]).resolve()
    instance_path = Path(sys.argv[2]).resolve()
    schema = json.loads(schema_path.read_text())
    instance = json.loads(instance_path.read_text())
    validate(instance, schema, schema_path.parent)
    print(f"PASS {instance_path.name} validates against {schema_path.name}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, json.JSONDecodeError, ValueError) as error:
        print(f"FAIL {error}", file=sys.stderr)
        raise SystemExit(1)
