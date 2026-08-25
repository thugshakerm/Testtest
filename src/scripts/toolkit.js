const $=s=>document.querySelector(s),checks=['Choose a target client build','Pair a matching RCCService build','Hash and document both binaries','Define required web/API endpoints','Configure isolated render testing','Review source and asset licenses','Create moderation and account-safety plan','Back up configuration and database'];$('#quick-checks').innerHTML=checks.map((x,i)=>`<label><input type="checkbox" data-i="${i}"> ${x}</label>`).join('');document.querySelectorAll('#quick-checks input').forEach(x=>{x.checked=localStorage.getItem('creator-check-'+x.dataset.i)==='1';x.onchange=()=>localStorage.setItem('creator-check-'+x.dataset.i,x.checked?'1':'0')});$('#menu').onclick=()=>document.querySelector('.side').classList.toggle('open');let fileMeta=null,last={};const file=$('#rcc-file'),drop=$('#drop');async function inspect(f){if(!f)return;let bytes=await f.arrayBuffer(),hash=[...new Uint8Array(await crypto.subtle.digest('SHA-256',bytes))].map(x=>x.toString(16).padStart(2,'0')).join('');fileMeta={name:f.name,size:f.size,modified:new Date(f.lastModified).toISOString(),sha256:hash};$('#file-info').innerHTML=`<dt>Name</dt><dd>${safe(f.name)}</dd><dt>Size</dt><dd>${f.size.toLocaleString()} bytes</dd><dt>SHA-256</dt><dd><code>${hash}</code></dd><dt>Privacy</dt><dd>Processed locally; not transmitted</dd>`}file.onchange=()=>inspect(file.files[0]);['dragenter','dragover'].forEach(e=>drop.addEventListener(e,x=>{x.preventDefault();drop.classList.add('drag')}));['dragleave','drop'].forEach(e=>drop.addEventListener(e,x=>{x.preventDefault();drop.classList.remove('drag')}));drop.addEventListener('drop',e=>inspect(e.dataTransfer.files[0]));function safe(s){let d=document.createElement('div');d.textContent=s;return d.innerHTML}function recipeLua(type,w,h){if(type==='health')return `return "RCC responsive: " .. tostring(os.time())`;let mode={avatar:'Avatar',place:'Place',headshot:'Closeup'}[type];return `-- Local render template; adapt APIs to the exact RCC build\nlocal width, height = ${w}, ${h}\nlocal renderMode = "${mode}"\n\n-- Load the intended place/avatar only from a trusted local source.\n-- Exact APIs differ by RCC build; verify before use.\nreturn { mode = renderMode, width = width, height = height }`}function generate(){let endpoint=$('#endpoint').value.replace(/\/$/,''),job=$('#job').value.replace(/[^a-zA-Z0-9_.-]/g,'-'),timeout=+$('#timeout').value,w=+$('#width').value,h=+$('#height').value,type=$('#recipe').value,lua=recipeLua(type,w,h),xml=`<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
 xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
 <soap:Body>
  <OpenJob xmlns="http://roblox.com/">
   <job>
    <id>${job}</id>
    <expirationInSeconds>${timeout}</expirationInSeconds>
    <category>1</category>
    <cores>1</cores>
   </job>
   <script>
    <name>${type}-render</name>
    <script><![CDATA[${lua}]]></script>
   </script>
  </OpenJob>
 </soap:Body>
</soap:Envelope>`,curl=`curl --fail-with-body --max-time ${timeout} \\
  -H "Content-Type: text/xml; charset=utf-8" \\
  -H "SOAPAction: http://roblox.com/OpenJob" \\
  --data-binary @render-request.xml \\
  "${endpoint}"`,report=`RCC LOCAL RESEARCH REPORT
=========================
Generated: ${new Date().toISOString()}
Endpoint: ${endpoint}
Job: ${job}
Recipe: ${type} (${w}x${h})
RCC file: ${fileMeta?.name||'not selected'}
RCC bytes: ${fileMeta?.size||'unknown'}
RCC SHA-256: ${fileMeta?.sha256||'unknown'}

Compatibility status: UNVERIFIED
This generator did not execute the binary or contact the endpoint.
Confirm WSDL action names and request schema against your exact RCC build.`;last={xml,lua,curl,report,config:{endpoint,job,timeout,w,h,type,file:fileMeta}};for(let [id,text] of [['soapout',xml],['luaout',lua],['curlout',curl],['reportout',report]])$('#'+id+' pre').textContent=text}$('#generate').onclick=generate;document.querySelectorAll('.tabs button').forEach(b=>b.onclick=()=>{document.querySelectorAll('.tabs button,.code').forEach(x=>x.classList.remove('on'));b.classList.add('on');$('#'+b.dataset.tab).classList.add('on')});document.querySelectorAll('.code>button').forEach(b=>b.onclick=()=>navigator.clipboard.writeText(b.nextElementSibling.textContent));function download(name,data,type='text/plain'){let a=document.createElement('a');a.href=URL.createObjectURL(new Blob([data],{type}));a.download=name;a.click();URL.revokeObjectURL(a.href)}$('#download-soap').onclick=()=>last.xml?download('render-request.xml',last.xml,'text/xml'):generate();$('#download-bundle').onclick=()=>{if(!last.xml)generate();download('rcc-render-bundle.json',JSON.stringify(last,null,2),'application/json')};const services=['Website frontend','Authentication API','Database','Asset storage','Thumbnail renderer / RCC','Game server orchestration','Moderation tools','Email delivery','Metrics and logs','Backups'];$('#services').innerHTML=services.map((x,i)=>`<label><input type="checkbox" data-service="${x}" ${i<7?'checked':''}> ${x}</label>`).join('');function architecture(){let active=[...document.querySelectorAll('[data-service]:checked')].map(x=>x.dataset.service),name=$('#project-name').value||'Untitled revival',era=$('#era').value,lineage=$('#lineage').value;$('#architecture').innerHTML=`<div><b>${safe(name)}</b><br>${era} target · ${safe(lineage)} interface</div>`+active.map(x=>`<div>${safe(x)}</div>`).join('');let n=Math.round(active.length/services.length*100);$('#meter').style.width=n+'%';$('#readiness').textContent=`${n}% of recommended service areas selected. Compatibility and security validation are still required.`;return {name,era,lineage,services:active,created:new Date().toISOString()}}document.querySelectorAll('#project input,#project select').forEach(x=>x.oninput=architecture);$('#export-project').onclick=()=>download('revival-blueprint.json',JSON.stringify(architecture(),null,2),'application/json');generate();architecture()