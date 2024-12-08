# Maximize Space

This action maximizes the space available to building. It inspired by [easimon/maximize-build-space](https://github.com/easimon/maximize-build-space).

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Maximize Build Space
        uses: gpustack/.github/actions/maximize-build-space@main
```

## Inputs

```yaml
inputs:
  deep-clean:
    description: 'Perform a deep clean, removing unnecessary packages.'
    required: false
    default: 'false'
```
