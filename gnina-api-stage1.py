import http.server
import socketserver
import tarfile
import tempfile
import shutil
import subprocess
import os

class RequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_PUT(self):
        length = int(self.headers['Content-Length'])
        with tempfile.NamedTemporaryFile(suffix='.tar.zst') as tmp:
            tmp.write(self.rfile.read(length))
            tmp.flush()
            subprocess.run(['tar', '-xf', tmp.name])
            subprocess.run(['touch', '/tmp/start'])
            
            try:
                # Check if there are files in /data
                if any(os.listdir('/data')):
                    self.send_response(200)
                    self.end_headers()
                    self.wfile.write(b'{"status": "ok"}')
                    return
            except:
                pass


    def do_GET(self):
        if self.path == '/result':
            self.send_response(200)
            self.send_header('Content-type', 'application/octet-stream')
            self.end_headers()
            with open('/tmp/tar.zst', 'rb') as file:
                shutil.copyfileobj(file, self.wfile)
                resultsSend = False
                exit()
                return
        self.send_response(200)
        self.end_headers()

        if not os.path.exists('/tmp/done'):
            self.wfile.write(b'{"status": "not ready"}')
            return

        self.wfile.write(b'{"status": "ready"}')
        return
resultsSend = False
PORT = 8222
with socketserver.TCPServer(('0.0.0.0', PORT), RequestHandler) as httpd:
    print(f"Serving on port {PORT}")
    httpd.handle_request()

    while resultsSend == False:
        httpd.handle_request()
