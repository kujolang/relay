import socketserver,socket,select,subprocess,ipaddress,threading
class Proxy(socketserver.BaseRequestHandler):
 def handle(self):
  self.request.settimeout(10);header=b''
  while b'\r\n\r\n' not in header and len(header)<8192:
   block=self.request.recv(1024)
   if not block:return
   header+=block
  if header.split(b'\r\n',1)[0]!=b'CONNECT ollama.com:443 HTTP/1.1':
   self.request.sendall(b'HTTP/1.1 403 Forbidden\r\n\r\n');return
  try:
   with socket.create_connection((self.server.upstream_ip,443),timeout=10) as upstream:
    self.request.sendall(b'HTTP/1.1 200 Connection Established\r\n\r\n');self.request.settimeout(None);upstream.settimeout(None)
    while True:
     ready,_,_=select.select([self.request,upstream],[],[],210)
     if not ready:return
     for src in ready:
      data=src.recv(65536)
      if not data:return
      (upstream if src is self.request else self.request).sendall(data)
  except (OSError,TimeoutError):return
class Server(socketserver.ThreadingTCPServer):
 daemon_threads=True
 allow_reuse_address=True
def start():
 answer=subprocess.check_output(['dig','+short','+time=3','+tries=1','ollama.com','A'],text=True,timeout=5)
 ip=next(str(ipaddress.IPv4Address(line)) for line in answer.splitlines() if line and line[0].isdigit())
 server=Server(('127.0.0.1',0),Proxy);server.upstream_ip=ip;threading.Thread(target=server.serve_forever,daemon=True).start();return server
if __name__=='__main__':
 import os
 server=start();e=os.environ.copy();e.update(HTTPS_PROXY='http://127.0.0.1:'+str(server.server_address[1]),NO_PROXY='127.0.0.1,localhost')
 try:subprocess.run(['/private/tmp/relay-review-env-20260922/kujo/target/release/kujo','run','/private/tmp/relay-http-probe.kujo','--interpreter'],env=e,timeout=30)
 finally:server.shutdown();server.server_close()
