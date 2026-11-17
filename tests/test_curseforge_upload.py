import hashlib
import importlib.util
import io
import json
from pathlib import Path
import unittest
import zipfile

path = Path(__file__).resolve().parents[1] / 'publishing' / 'curseforge_upload.py'
spec = importlib.util.spec_from_file_location('upload', path)
upload = importlib.util.module_from_spec(spec)
spec.loader.exec_module(upload)


class UploadChecks(unittest.TestCase):
    def package(self, name='MarketLedger/MarketLedger.toc', version='1.3.7'):
        stream = io.BytesIO()
        with zipfile.ZipFile(stream, 'w') as z:
            z.writestr(name, f'## Version: {version}\n## Interface: 16001\n')
        data = stream.getvalue()
        return data, {'sha256': hashlib.sha256(data).hexdigest(), 'version': '1.3.7'}

    def test_valid_zip(self):
        data, release = self.package()
        upload.validate_zip(data, 'MarketLedger', release)

    def test_changed_bytes_rejected(self):
        data, release = self.package()
        with self.assertRaises(ValueError):
            upload.validate_zip(data + b'changed', 'MarketLedger', release)

    def test_wrong_version_rejected(self):
        data, release = self.package(version='1.3.6')
        with self.assertRaises(ValueError):
            upload.validate_zip(data, 'MarketLedger', release)

    def test_traversal_rejected(self):
        data, release = self.package(name='../MarketLedger/MarketLedger.toc')
        with self.assertRaises(ValueError):
            upload.validate_zip(data, 'MarketLedger', release)

    def test_version_resolution_and_optional_relation(self):
        config = json.loads((upload.ROOT / 'releases.json').read_text())['ProfessionPal']
        meta = upload.metadata(config, [{'name': '1.60.1', 'id': 123}])
        self.assertEqual(meta['gameVersions'], [123])
        self.assertEqual(meta['relations']['projects'][0]['type'], 'optionalDependency')
        self.assertIsInstance(meta['relations']['projects'][0]['projectID'], int)
        for versions in [[], [{'name': '1.60.1', 'id': 1}, {'name': '1.60.1', 'id': 2}]]:
            with self.assertRaises(ValueError):
                upload.metadata(config, versions)

    def test_multipart_preserves_zip(self):
        data, _ = self.package()
        body, content_type = upload.multipart({'displayName': 'Test'}, 'MarketLedger', data)
        self.assertIn(data, body)
        self.assertIn(b'name="metadata"', body)
        self.assertIn(b'filename="MarketLedger.zip"', body)
        self.assertTrue(content_type.startswith('multipart/form-data; boundary='))


if __name__ == '__main__':
    unittest.main()
