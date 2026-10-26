#!/usr/bin/env node
// Plumbline kit command line.
//
//   plumbline-kit migrations <supabase-dir>   copy the kit's migrations into <supabase-dir>/migrations
//   plumbline-kit tests <supabase-dir>        copy the kit's database tests into <supabase-dir>/tests/plumbline-kit
//
// Files are copied by name and never deleted; an existing file with the same name is replaced only if
// its content differs, and the command says so. Kit migrations are named with fixed timestamps per kit
// version, so they sort before an app's own later migrations.
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const kit = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const [cmd, target] = process.argv.slice(2);

function copyDir(from, to, filter) {
  mkdirSync(to, { recursive: true });
  let added = 0, replaced = 0, same = 0;
  for (const name of readdirSync(from, { withFileTypes: true })) {
    const src = join(from, name.name), dst = join(to, name.name);
    if (name.isDirectory()) { const r = copyDir(src, dst, filter); added += r.added; replaced += r.replaced; same += r.same; continue; }
    if (!filter(name.name)) continue;
    if (existsSync(dst)) {
      if (readFileSync(dst, 'utf8') === readFileSync(src, 'utf8')) { same++; continue; }
      console.log(`replaced ${dst}`); replaced++;
    } else { added++; }
    cpSync(src, dst);
  }
  return { added, replaced, same };
}

if (!target || !['migrations', 'tests'].includes(cmd)) {
  console.error('usage: plumbline-kit <migrations|tests> <supabase-dir>');
  process.exit(2);
}
if (!existsSync(target)) { console.error(`no such directory: ${target}`); process.exit(2); }

const r = cmd === 'migrations'
  ? copyDir(join(kit, 'migrations'), join(target, 'migrations'), (n) => n.endsWith('.sql'))
  : copyDir(join(kit, 'tests'), join(target, 'tests', 'plumbline-kit'), (n) => n.endsWith('.sql') || n.endsWith('.psql'));
console.log(`plumbline-kit ${cmd}: ${r.added} added, ${r.replaced} replaced, ${r.same} unchanged`);
