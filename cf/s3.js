// Simple Storage Service - 2025/01/11
// Fork of https://github.com/YuukioFuyu/Serverless-Temp-File-Sharing
const config = {
  // All variables here are required.
  GOOGLE_CLIENT_ID: "",
  GOOGLE_CLIENT_SECRET: "",
  GOOGLE_REFRESH_TOKEN: "",
  DESTINATION_FOLDER_ID: "",
};
  
// Event Listener for Requests
addEventListener('fetch', (event) => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  const url = new URL(request.url);
  const host = request.headers.get("host");
  const colo = request.cf.colo;
  const timestamp = Math.floor(Date.now() / 1000);
  // Handle different routes
  if (url.pathname === "/") {
    return new Response(uploadPage, {
      headers: { 'content-type': 'text/html', 'cache-control': 'no-store' },
    });
  } else if (url.pathname === "/receipt") {
    const fileId = url.searchParams.get("id");
    const fileExistsAndName = await getFileMetadata(fileId);
    if (fileExistsAndName.exists) {
      const fileSize = await getFileSize(fileId);
      const fileLink = `https://${host}/download?id=${fileId}`;
      return new Response(downloadPage(fileLink, fileExistsAndName.name, fileSize, colo, timestamp), {
        headers: { 'content-type': 'text/html', 'cache-control': 'no-store' },
      });
    } else {
      return new Response(notfoundPage(colo, timestamp), {
        headers: { 'content-type': 'text/html', 'cache-control': 'no-store' },
      });
    }
  } else if (url.pathname === "/download") {
    const fileId = url.searchParams.get("id");
    const fileMetadata = await getFileMetadata(fileId);
    if (fileMetadata.exists) {
      const file = await downloadFile(fileId);
      if (file) {
        return new Response(file, {
          headers: {
            "content-type": "application/octet-stream",
            "content-disposition": `attachment; filename="${fileMetadata.name}"`,
          },
        });
      }
    }
    return Response.redirect(`https://${host}/receipt?id=${fileId}`);
  } else if (url.pathname === "/upload" && request.method === "POST") {
    try {
      const formData = await request.formData();
      const file = formData.get("file");
      const fileId = await uploadFileToDrive(file);
      if (fileId) {
        return Response.redirect(`https://${host}/receipt?id=${fileId}`);
      }
      return new Response("Upload failed", { status: 500 });
    } catch (error) {
      return new Response("Error processing upload", { status: 500 });
    }
  }
  return Response.redirect(`https://${host}/`, 302);
}

// Google Drive API Functions
async function uploadFileToDrive(file) {
  const accessToken = await getAccessToken();
  const metadata = {
    name: file.name,
    mimeType: file.type,
    parents: [config.DESTINATION_FOLDER_ID],
  };
  const form = new FormData();
  form.append("metadata", new Blob([JSON.stringify(metadata)], { type: "application/json" }));
  form.append("file", file);
  const response = await fetch("https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart", {
    method: "POST",
    headers: { Authorization: `Bearer ${accessToken}` },
    body: form,
  });
  const data = await response.json();
  return data.id;
}

async function downloadFile(fileId) {
  const accessToken = await getAccessToken();
  const response = await fetch(`https://www.googleapis.com/drive/v3/files/${fileId}?alt=media`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (response.ok) {
    return new Uint8Array(await response.arrayBuffer());
  }
  return null;
}

async function getFileMetadata(fileId) {
  const accessToken = await getAccessToken();
  const response = await fetch(`https://www.googleapis.com/drive/v3/files/${fileId}?fields=name,size`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (response.ok) {
    const data = await response.json();
    return { exists: true, name: data.name, size: data.size };
  } else {
    return { exists: false, name: null, size: null };
  }
}

function formatFileSize(bytes) {
  if (bytes === 0) return '0.00 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  let size = bytes;
  let unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return `${size.toFixed(2)} ${units[unitIndex]}`;
}

async function getFileSize(fileId) {
  const metadata = await getFileMetadata(fileId);
  if (metadata.exists) {
    return formatFileSize(metadata.size);
  }
  return 'Unknown size';
}

async function getAccessToken() {
  const response = await fetch("https://www.googleapis.com/oauth2/v4/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: config.GOOGLE_CLIENT_ID,
      client_secret: config.GOOGLE_CLIENT_SECRET,
      refresh_token: config.GOOGLE_REFRESH_TOKEN,
      grant_type: "refresh_token",
    }),
  });
  const data = await response.json();
  return data.access_token;
}
  
// HTML PAGES GO HERE YAY
const uploadPage = `
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta name="robots" content="noindex, noimageindex, nofollow, noarchive, nosnippet">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📦</text></svg>">
      <title>Simple Storage Service</title>
      <link href="https://fonts.googleapis.com/css2?family=VT323&display=swap" rel="stylesheet">
      <style>:root{--text-color:#e0e2f4;--bg-color:#212121;--highlight-color:#aaa;--status-text-color:#777}body{background:var(--bg-color);display:flex;justify-content:center;align-items:center;color:var(--text-color);font:normal 20px/1.25rem 'VT323',monospace;font-family:VT323,Arial,sans-serif}.container{width:90%;margin:auto;max-width:640px;padding-top:5%;padding-bottom:5%}h1,h2,h3{text-align:center}h1{font:normal 2.75rem/1.05em 'VT323',monospace;margin:20px 0}h2{font:normal 2rem/1.25em 'VT323',monospace;margin:0 0 5px 0}p,a,button{font:normal 1.25rem 'VT323',monospace;text-align:center;margin:0}.highlight-background{background:var(--highlight-color);color:var(--bg-color);padding:0 15px}.highlight-background::selection{background-color:var(--bg-color);color:var(--highlight-color);padding:1px 15px}nav{margin:20px 0;text-align:center}a,button{text-decoration:none;color:var(--text-color);background:none;border:none;cursor:pointer;position:relative}button{padding:0 5px;margin:0 5px}.status{font-size:0.9rem;color:var(--status-text-color)}button::before,button::after{content:'';position:absolute;top:0;font-size:1.25rem;transition:transform 0.2s ease}button::before{content:'[';left:-3px;color:var(--text-color)}button::after{content:']';right:-3px;color:var(--text-color)}a:hover,a:focus,button:hover,button:focus{background:var(--highlight-color);color:var(--bg-color)}button:hover::before,button:focus::before{transform:translateX(-5px);color:var(--bg-color)}button:hover::after,button:focus::after{transform:translateX(5px);color:var(--bg-color)}button:hover span,button:focus span{color:var(--bg-color)}button:hover::before,button:focus::before,button:hover::after,button:focus::after{background:var(--highlight-color)}::selection{background-color:var(--highlight-color);color:var(--bg-color);padding:2px 15px}br,spacer{display:block;content:""}br{margin-top:0}spacer{margin-top:1em}</style>
      <style>.upload-form{text-align:center;margin:2rem 0}.file-input-container{border:2px dashed var(--text-color);padding:2rem;margin-bottom:1.5rem;display:flex;flex-direction:column;align-items:center;gap:1rem;transition:background-color 0.3s,border-color 0.3s}.file-input-container.drag-over{background-color:rgb(224 226 244 / .1);border-color:var(--highlight-color)}.file-input-container.uploading{border-style:solid}.file-input{display:none}.file-status{font:normal 1.25rem 'VT323',monospace;color:var(--text-color);margin:0}.file-name{font:normal 1.25rem 'VT323',monospace;color:var(--text-color);margin:0;white-space:normal;word-wrap:break-word;max-width:100%;text-align:center;overflow-wrap:break-word}.file-selector{font:normal 1.25rem 'VT323',monospace;color:var(--text-color);background:none;border:none;cursor:pointer}.file-selector:hover{background:var(--highlight-color);color:var(--bg-color)}.upload-button{display:none}.progress-info{display:none;text-align:center;margin-top:1rem}.progress-info p{margin:.25rem 0}.size-info,.speed-info,.eta-info{font:normal 1.25rem 'VT323',monospace;color:var(--text-color);margin:.25rem 0}.notice-message{color:var(--text-color);margin-top:1rem}</style>
    </head>
    <body>
      <div class="container">
        <section>
          <h1 class="page-title">
            <span class="highlight-background">Simple Storage Service</span>
          </h1>
          <p class="notice-message" id="notice-message">Only 1 file can be uploaded at a time</p>
          <form id="uploadForm" class="upload-form">
            <div class="file-input-container" id="drop-zone">
              <p class="file-status" id="file-status">Drag and drop your file here, or click the button below.</p>
              <p class="file-name" id="file-name"></p>
              <input type="file" name="file" class="file-input" id="file-input" style="display: none;">
              <button type="button" class="file-selector" id="file-selector">Select File</button>
              <div class="progress-info" id="progress-info">
                <p class="upload-percentage" id="upload-percentage"></p>
                <p class="size-info" id="size-info"></p>
                <p class="speed-info" id="speed-info"></p>
                <p class="eta-info" id="eta-info"></p>
              </div>
            </div>
            <button type="submit" class="upload-button" id="upload-button">Upload File</button>
          </form>
        </section>
      </div>
      <script>var strings={dragMessage:"Drag and drop your file here, or click the button below.",releaseFile:"Release to select file.",noticeSingleFile:"Only 1 (one) file can be uploaded at a time",noticeUploading:"Please do not leave or close this page"},dropZone=document.getElementById("drop-zone"),fileInput=document.getElementById("file-input"),fileStatus=document.getElementById("file-status"),fileName=document.getElementById("file-name"),fileSelector=document.getElementById("file-selector"),uploadButton=document.getElementById("upload-button"),form=document.getElementById("uploadForm"),progressInfo=document.getElementById("progress-info"),uploadPercentage=document.getElementById("upload-percentage"),sizeInfo=document.getElementById("size-info"),speedInfo=document.getElementById("speed-info"),etaInfo=document.getElementById("eta-info"),noticeMessage=document.getElementById("notice-message"),isUploading=!1,uploadStartTime,lastLoaded=0,lastTime=0,selectedFile;function formatSize(e){for(var t of["B","KB","MB","GB"]){if(e<1024)return e.toFixed(2)+" "+t;e/=1024}return e.toFixed(2)+" TB"}function formatSpeed(e){return e<=0?"0 B/s":e>=1048576?(e/1048576).toFixed(2)+" MB/s":e>=1024?(e/1024).toFixed(2)+" KB/s":e.toFixed(2)+" B/s"}function formatTime(e){e=Math.ceil(e);var t=Math.floor(e/3600),o=Math.floor(e%3600/60),n=e%60,r=[];return t>0&&r.push(t+" hour"+(t>1?"s":"")),(o>0||t>0&&n>0)&&r.push(o+" minute"+(o>1?"s":"")),(n>0||0===r.length)&&r.push(n+" second"+(n>1?"s":"")),r.join(" ")}function resetUploadState(){fileStatus.textContent=strings.dragMessage,fileName.textContent="",fileSelector.textContent="Select File",uploadButton.style.display="none",dropZone.classList.remove("uploading"),progressInfo.style.display="none",noticeMessage.textContent=strings.noticeSingleFile,noticeMessage.style.display="block",isUploading=!1,selectedFile=null}function preventDefaults(e){e.preventDefault(),e.stopPropagation()}function highlight(e){isUploading||(dropZone.classList.add("drag-over"),fileStatus.textContent=strings.releaseFile)}function unhighlight(e){isUploading||(dropZone.classList.remove("drag-over"),fileStatus.textContent=selectedFile?"Selected File:":strings.dragMessage)}function handleDrop(e){if(!isUploading){var t=e.dataTransfer.files;t.length>0&&(selectedFile=t[0],updateFileDisplay())}}form.addEventListener("submit",async function(e){if(e.preventDefault(),!isUploading&&selectedFile){isUploading=!0,uploadStartTime=Date.now(),lastLoaded=0,lastTime=uploadStartTime,fileSelector.style.display="none",uploadButton.style.display="none",dropZone.classList.add("uploading"),progressInfo.style.display="block",noticeMessage.textContent=strings.noticeUploading,noticeMessage.style.display="block",fileStatus.textContent="Uploading";var t=new FormData;t.append("file",selectedFile);var o=new XMLHttpRequest;o.open("POST","/upload",!0),o.upload.onprogress=function(e){if(e.lengthComputable){var t=Date.now(),n=(t-lastTime)/1e3,r=e.loaded-lastLoaded,a=r/n,s=(e.total-e.loaded)/a,i=e.loaded/e.total*100;uploadPercentage.textContent=i.toFixed(2)+"%",sizeInfo.textContent=formatSize(e.loaded)+" of "+formatSize(e.total),speedInfo.textContent=formatSpeed(a),etaInfo.textContent="ETA: "+formatTime(s),lastLoaded=e.loaded,lastTime=t}},o.onload=function(){200===o.status?o.responseURL?window.location.href=o.responseURL:console.error("No response URL or data found."):alert("Upload failed with status "+o.status),resetUploadState()},o.onerror=function(){alert("An error occurred during upload."),resetUploadState()},o.send(t)}}),fileInput.addEventListener("change",function(e){this.files[0]?(selectedFile=this.files[0],updateFileDisplay()):(selectedFile=null,updateFileDisplay())});function updateFileDisplay(){selectedFile?(fileName.textContent=selectedFile.name,fileStatus.textContent="Selected File:",fileSelector.textContent="Reselect File",uploadButton.style.display="inline"):(fileName.textContent="",fileStatus.textContent=strings.dragMessage,fileSelector.textContent="Select File",uploadButton.style.display="none")}document.getElementById("file-selector").addEventListener("click",function(){document.getElementById("file-input").click()}),["dragenter","dragover","dragleave","drop"].forEach(function(e){dropZone.addEventListener(e,preventDefaults,!1),document.body.addEventListener(e,preventDefaults,!1)}),["dragenter","dragover"].forEach(function(e){dropZone.addEventListener(e,highlight,!1)}),["dragleave","drop"].forEach(function(e){dropZone.addEventListener(e,unhighlight,!1)}),dropZone.addEventListener("drop",handleDrop,!1); </script>
    </body>
  </html>
`;
  
function downloadPage(fileLink, fileName, fileSize, colo, timestamp) {
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="robots" content="noindex, noimageindex, nofollow, noarchive, nosnippet">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📦</text></svg>">
        <title>Simple Storage Service</title>
        <link href="https://fonts.googleapis.com/css2?family=VT323&display=swap" rel="stylesheet">
        <style>:root{--text-color:#e0e2f4;--bg-color:#212121;--highlight-color:#aaa;--status-text-color:#777}body{background:var(--bg-color);display:flex;justify-content:center;align-items:center;color:var(--text-color);font:normal 20px/1.25rem 'VT323',monospace;font-family:VT323,Arial,sans-serif}.container{width:90%;margin:auto;max-width:640px;padding-top:5%;padding-bottom:5%}h1,h2,h3{text-align:center}h1{font:normal 2.75rem/1.05em 'VT323',monospace;margin:20px 0}h2{font:normal 2rem/1.25em 'VT323',monospace;margin:0 0 5px 0}p,a,button{font:normal 1.25rem 'VT323',monospace;text-align:center;margin:0}.highlight-background{background:var(--highlight-color);color:var(--bg-color);padding:0 15px}.highlight-background::selection{background-color:var(--bg-color);color:var(--highlight-color);padding:1px 15px}nav{margin:20px 0;text-align:center}a,button{text-decoration:none;color:var(--text-color);background:none;border:none;cursor:pointer;position:relative}button{padding:0 5px;margin:0 5px}.status{font-size:0.9rem;color:var(--status-text-color)}button::before,button::after{content:'';position:absolute;top:0;font-size:1.25rem;transition:transform 0.2s ease}button::before{content:'[';left:-3px;color:var(--text-color)}button::after{content:']';right:-3px;color:var(--text-color)}a:hover,a:focus,button:hover,button:focus{background:var(--highlight-color);color:var(--bg-color)}button:hover::before,button:focus::before{transform:translateX(-5px);color:var(--bg-color)}button:hover::after,button:focus::after{transform:translateX(5px);color:var(--bg-color)}button:hover span,button:focus span{color:var(--bg-color)}button:hover::before,button:focus::before,button:hover::after,button:focus::after{background:var(--highlight-color)}::selection{background-color:var(--highlight-color);color:var(--bg-color);padding:2px 15px}br,spacer{display:block;content:""}br{margin-top:0}spacer{margin-top:1em}</style>
      </head>
      <body>
        <div class="container">
          <section>
            <h1>
              <span class="highlight-background">Simple Storage Service</span>
            </h1>
            <p>${fileName}</p>
            <p>${fileSize}</p>
          </section>
          <spacer></spacer>
          <nav>
            <button onclick="window.location.href='${fileLink}';"><span>Download File</span></button>
            <button onclick="copyLink(this, '${fileLink}')"><span>Copy Link</span></button>
          </nav>
          <nav>
            <button onclick="window.history.back();"><span>Go Back</span></button>
          </nav>
          <p class="status" id="status">Served by Cloudflare ${colo}<br>${timestamp}</p>
        </div>
        <script>async function copyLink(button,link){try{await navigator.clipboard.writeText(link);let span=button.getElementsByTagName('span')[0];let originalText=span.textContent;span.textContent='Link Copied!';setTimeout(()=>{span.textContent=originalText},3000)}catch(e){console.error('Failed to copy link:',e)}}</script>
      </body>
    </html>
  `;
}

function notfoundPage(colo, timestamp) {
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="robots" content="noindex, noimageindex, nofollow, noarchive, nosnippet">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📦</text></svg>">
        <title>File Not Found</title>
        <link href="https://fonts.googleapis.com/css2?family=VT323&display=swap" rel="stylesheet">
        <style>:root{--text-color:#e0e2f4;--bg-color:#212121;--highlight-color:#aaa;--status-text-color:#777}body{background:var(--bg-color);display:flex;justify-content:center;align-items:center;color:var(--text-color);font:normal 20px/1.25rem 'VT323',monospace;font-family:VT323,Arial,sans-serif}.container{width:90%;margin:auto;max-width:640px;padding-top:5%;padding-bottom:5%}h1,h2,h3{text-align:center}h1{font:normal 2.75rem/1.05em 'VT323',monospace;margin:20px 0}h2{font:normal 2rem/1.25em 'VT323',monospace;margin:0 0 5px 0}p,a,button{font:normal 1.25rem 'VT323',monospace;text-align:center;margin:0}.highlight-background{background:var(--highlight-color);color:var(--bg-color);padding:0 15px}.highlight-background::selection{background-color:var(--bg-color);color:var(--highlight-color);padding:1px 15px}nav{margin:20px 0;text-align:center}a,button{text-decoration:none;color:var(--text-color);background:none;border:none;cursor:pointer;position:relative}button{padding:0 5px;margin:0 5px}.status{font-size:0.9rem;color:var(--status-text-color)}button::before,button::after{content:'';position:absolute;top:0;font-size:1.25rem;transition:transform 0.2s ease}button::before{content:'[';left:-3px;color:var(--text-color)}button::after{content:']';right:-3px;color:var(--text-color)}a:hover,a:focus,button:hover,button:focus{background:var(--highlight-color);color:var(--bg-color)}button:hover::before,button:focus::before{transform:translateX(-5px);color:var(--bg-color)}button:hover::after,button:focus::after{transform:translateX(5px);color:var(--bg-color)}button:hover span,button:focus span{color:var(--bg-color)}button:hover::before,button:focus::before,button:hover::after,button:focus::after{background:var(--highlight-color)}::selection{background-color:var(--highlight-color);color:var(--bg-color);padding:2px 15px}br,spacer{display:block;content:""}br{margin-top:0}spacer{margin-top:1em}</style>
      </head>
      <body>
        <div class="container">
          <section>
            <h1>
              <span class="highlight-background">File Not Found</span>
            </h1>
            <p>Sorry, the file you have requested could not be found.<br>The link may be incorrect or the file you're looking for is no longer available.</p>
          </section>
          <spacer></spacer>
          <nav>
            <button onclick="location.reload(true);"><span>Refresh</span></button>
            <button onclick="window.history.back();"><span>Go Back</span></button>
          </nav>
          <p class="status" id="status">Served by Cloudflare ${colo}<br>${timestamp}</p>
        </div>
      </body>
    </html>
  `;
}
