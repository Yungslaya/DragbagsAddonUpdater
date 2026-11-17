"""Manual CurseForge upload of checksum-pinned releases; never edits project pages."""
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import sys
import urllib.error
import urllib.request
import uuid
import zipfile

ROOT = Path(__file__).resolve().parent
API = 'https://wow.curseforge.com/api'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise RuntimeError('CurseForge redirected the authenticated request; stopped.')


def cf_request(path, token, data=None, content_type=None):
    headers = {'X-Api-Token': token, 'Accept': 'application/json'}
    if content_type:
        headers['Content-Type'] = content_type
    req = urllib.request.Request(API + path, data=data, headers=headers)
    try:
        with urllib.request.build_opener(NoRedirect()).open(req, timeout=90) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        raise RuntimeError(f'CurseForge HTTP {e.code}; inspect account permissions before retrying.') from None
    except (urllib.error.URLError, TimeoutError):
        raise RuntimeError('CurseForge connection failed. If uploading, inspect the project files before retrying; the upload may have arrived.') from None


def validate_zip(data, addon, release):
    if hashlib.sha256(data).hexdigest() != release['sha256']:
        raise ValueError('Release ZIP checksum changed; refusing upload.')
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        names = z.namelist()
        if len(set(names)) != len(names):
            raise ValueError('Duplicate ZIP members.')
        for name in names:
            p = PurePosixPath(name)
            if p.is_absolute() or '..' in p.parts or p.parts[0] != addon:
                raise ValueError('Unexpected ZIP path.')
            if not name.endswith('/') and p.suffix.lower() not in {'.lua', '.toc', '.xml', '.txt'}:
                raise ValueError('Unexpected file in addon ZIP.')
        toc = z.read(f'{addon}/{addon}.toc').decode('utf-8-sig')
        if f'## Version: {release["version"]}' not in toc.splitlines():
            raise ValueError('TOC version differs from reviewed release.')
        if '## Interface: 16001' not in toc.splitlines():
            raise ValueError('Unexpected game interface.')


def metadata(release, versions):
    matches = [v for v in versions if v.get('name') == '1.60.1']
    if len(matches) != 1 or not isinstance(matches[0].get('id'), int):
        raise ValueError('Cannot uniquely identify WoW Forever 1.60.1; stop and verify version IDs.')
    return {
        'displayName': release['display_name'],
        'changelog': (ROOT / release['changelog']).read_text(),
        'changelogType': 'markdown',
        'gameVersions': [matches[0]['id']],
        'releaseType': 'release',
        'relations': {'projects': release['relations']},
    }


def multipart(meta, addon, data):
    boundary = 'curseforge-' + uuid.uuid4().hex
    prefix = (
        f'--{boundary}\r\nContent-Disposition: form-data; name="metadata"\r\n'
        f'Content-Type: application/json\r\n\r\n{json.dumps(meta)}\r\n'
        f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{addon}.zip"\r\n'
        'Content-Type: application/zip\r\n\r\n'
    ).encode()
    return prefix + data + f'\r\n--{boundary}--\r\n'.encode(), f'multipart/form-data; boundary={boundary}'


def main():
    addon = os.environ.get('ADDON')
    config = json.loads((ROOT / 'releases.json').read_text())
    if addon not in config:
        raise ValueError('Select one of the configured addons.')
    release = config[addon]
    token = os.environ.get('CURSEFORGE_API_TOKEN', '').strip()
    if not token:
        raise ValueError('Add the CURSEFORGE_API_TOKEN repository Actions secret first.')
    url = f'https://github.com/Yungslaya/{addon}/releases/download/v{release["version"]}/{addon}.zip'
    with urllib.request.urlopen(url, timeout=90) as response:
        data = response.read()
    validate_zip(data, addon, release)
    meta = metadata(release, cf_request('/game/versions', token))
    print(f'Validated {meta["displayName"]}, ZIP checksum, game version and token access.')
    if os.environ.get('PUBLISH', '').lower() != 'true':
        print('Validation only: nothing uploaded. Project write access is established only by a successful upload.')
        return
    body, content_type = multipart(meta, addon, data)
    result = cf_request(f'/projects/{release["project_id"]}/upload-file', token, body, content_type)
    if not isinstance(result.get('id'), int):
        raise RuntimeError('Upload response had no file ID; inspect project files before retrying.')
    message = f'Uploaded {meta["displayName"]}: CurseForge file ID {result["id"]}. Approval/public availability must be checked on CurseForge.'
    print(message)
    if os.environ.get('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as f:
            f.write(message + '\n')


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        # No response bodies, headers, tokens, or authenticated request objects in logs.
        print(f'Upload stopped: {e}', file=sys.stderr)
        sys.exit(1)
