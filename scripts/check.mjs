import { readFileSync, existsSync } from 'node:fs'
const pages=['index.html','styleguide.html','reverse-engineering-wiki.html','toolkit.html']
for(const page of pages){if(!existsSync(page))throw new Error(`Missing ${page}`);const html=readFileSync(page,'utf8');for(const m of html.matchAll(/(?:src|href)="(\/src\/[^"]+)"/g)){if(!existsSync(m[1].slice(1)))throw new Error(`${page}: missing ${m[1]}`)}}
const manifest=JSON.parse(readFileSync('assets/manifest.json','utf8'));if(manifest.uniqueFiles!==5764)throw new Error('Asset manifest count changed unexpectedly')
console.log(`Checked ${pages.length} pages and ${manifest.uniqueFiles} unique assets.`)
