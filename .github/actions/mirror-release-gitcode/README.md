# Mirror Release to GitCode

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Mirror Release to GitCode
        uses: gpustack/.github/actions/mirror-release-to-gitcode@main
```

## Input

```yaml
inputs:
  gitcode-username:
    description: 'GitCode username to upload release assets.'
    required: true
  gitcode-password:
    description: 'GitCode password to login GitCode.'
    required: true
  gitcode-token:
    description: 'GitCode token to upload release assets.'
    required: true
  gitcode-repository:
    description: 'Target GitCode repository, inform of "owner/name", usually the same as Source Github repository.'
    required: false
    default: ''
  max-releases: 
    description: 'Numer of the latest releases to mirror.'
    required: false
    default: '1'
  github-token:
    description: 'Github token to donwload releases from Github repository, usually inherit from the composition action.'
    required: false
    default: ''
  github-repository:
    description: 'Source Github repository, inform of "owner/name", usually inherit from the composition action.'
    required: false
    default: ''
  dry-run:
    description: 'Skip writing operations.'
    required: false
    default: 'false'
```
