'use strict';
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const {execFileSync} = require('node:child_process');
const root = path.resolve(__dirname, '../..');
const config = require('./tailwind.config.cjs');
const version = require('tailwindcss/package.json').version;
if (version !== '3.4.17') throw new Error('The pinned Tailwind compiler 3.4.17 is required');
const output = path.join(root, 'assets/css/lecture_utilities.css');
const temporary = output + '.pending';
try {
  execFileSync(process.execPath, [require.resolve('tailwindcss/lib/cli.js'), '--config', path.join(__dirname, 'tailwind.config.cjs'), '--input', path.join(__dirname, 'input.css'), '--output', temporary, '--minify'], {cwd: __dirname, stdio: 'inherit'});
  fs.renameSync(temporary, output);
} finally {if (fs.existsSync(temporary)) fs.unlinkSync(temporary);}
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const record = file => ({path: path.relative(root, file).split(path.sep).join('/'), sha256: sha(file), bytes: fs.statSync(file).size});
const manifest = {compiler: 'tailwindcss', version, source: 'package-lock.json pins compiler and transitive npm dependencies', method: 'Static source extraction plus explicit safelist for interpolated colour classes; no native browser layout acceptance', inputs: [...config.content, ...['input.css','tailwind.config.cjs','build_tailwind.cjs','package.json','package-lock.json'].map(n => path.join(__dirname,n))].map(record), output: record(output)};
fs.writeFileSync(path.join(__dirname, 'TAILWIND_MANIFEST.json'), JSON.stringify(manifest, null, 2)+'\n');
console.log(`Compiled ${config.content.length} lecture documents with Tailwind ${version}; ${manifest.output.bytes} CSS bytes`);
