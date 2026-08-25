const $=s=>document.querySelector(s),editor=$('#editor'),highlight=$('#highlight'),lines=$('#lines'),frame=$('#preview');const starter=`<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Revival Page</title>
  <style>
    body { margin: 0; background: #f8fafc; font-family: Arial, sans-serif; }
    nav { padding: 14px 6%; color: white; background: rgb(71, 73, 189); }
    main { max-width: 960px; margin: auto; padding: 48px 24px; }
    .card { padding: 24px; background: white; border: 1px solid #ddd; border-radius: 6px; }
  </style>
</head>
<body>
  <nav><strong>My Revival</strong></nav>
  <main>
    <section class="card">
      <h1>We make old new again.</h1>
      <p>Edit this HTML to update the live preview.</p>
    </section>
  </main>
</body>
</html>`;editor.value=localStorage.getItem('html-viewer-document')||starter;let timer;function esc(s){return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')}function colorize(s){return esc(s).replace(/(&lt;!--[\s\S]*?--&gt;)/g,'<span class="comment">$1</span>').replace(/(&lt;!doctype[^&]*&gt;)/gi,'<span class="doctype">$1</span>').replace(/(&lt;\/?)([\w-]+)/g,'$1<span class="tag">$2</span>').replace(/([\w-]+)(=)(&quot;[^&]*?&quot;|"[^"]*")/g,'<span class="attr">$1</span>$2<span class="str">$3</span>')}function update(run=true){highlight.innerHTML=colorize(editor.value)+'\n';let n=editor.value.split('\n').length;lines.textContent=Array.from({length:n},(_,i)=>i+1).join('\n');localStorage.setItem('html-viewer-document',editor.value);outline();cursor();if(run){clearTimeout(timer);timer=setTimeout(()=>frame.srcdoc=editor.value,250)}}function outline(){let doc=new DOMParser().parseFromString(editor.value,'text/html'),items=[...doc.querySelectorAll('h1,h2,h3,nav,main,section')].slice(0,25);$('#outline').innerHTML=items.length?items.map(x=>`<div>${x.tagName.toLowerCase()} ${x.id?'#'+x.id:(x.textContent||'').trim().slice(0,20)}</div>`).join(''):'No symbols found'}function cursor(){let before=editor.value.slice(0,editor.selectionStart).split('\n');$('#cursor').textContent=`Ln ${before.length}, Col ${before.at(-1).length+1}`}editor.oninput=()=>update();editor.onscroll=()=>{highlight.scrollTop=editor.scrollTop;highlight.scrollLeft=editor.scrollLeft;lines.scrollTop=editor.scrollTop};editor.onkeyup=editor.onclick=cursor;editor.onkeydown=e=>{if(e.key==='Tab'){e.preventDefault();let a=editor.selectionStart,b=editor.selectionEnd;editor.setRangeText('  ',a,b,'end');update()}};function load(f){if(!f)return;let r=new FileReader;r.onload=()=>{editor.value=r.result;$('#filename').textContent=$('#tabname').textContent=f.name;update()};r.readAsText(f)}$('#file').onchange=e=>load(e.target.files[0]);$('#open-file').onclick=()=>$('#file').click();$('#refresh').onclick=()=>frame.srcdoc=editor.value;document.querySelectorAll('.device button').forEach(b=>b.onclick=()=>{document.querySelectorAll('.device button').forEach(x=>x.classList.remove('on'));b.classList.add('on');frame.style.width=b.dataset.width});$('#split').onclick=()=>{if(innerWidth<850)document.querySelector('.editor-area').classList.toggle('preview-mobile');else document.querySelector('.editor-area').classList.toggle('hide-preview')};$('#wrap').onclick=()=>$('.code-stack').classList.toggle('wrap');$('#format').onclick=()=>{let depth=0,out=[];for(let line of editor.value.replace(/>\s*</g,'>\n<').split('\n')){line=line.trim();if(/^<\//.test(line))depth=Math.max(0,depth-1);out.push('  '.repeat(depth)+line);if(/^<[^!/][^>]*>$/.test(line)&&!/<\/|\/>|<(meta|link|img|input|br|hr)/i.test(line))depth++}editor.value=out.join('\n');update()};$('#external').onclick=()=>{let w=open();w.document.write(editor.value);w.document.close()};function download(){let a=document.createElement('a');a.href=URL.createObjectURL(new Blob([editor.value],{type:'text/html'}));a.download=$('#filename').textContent||'index.html';a.click();URL.revokeObjectURL(a.href)}$('#download').onclick=download;update()