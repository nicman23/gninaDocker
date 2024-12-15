import asyncio
import websockets
import tarfile
import tempfile
import shutil
import subprocess

async def handle_socket(websocket, path):
    peer = websocket.remote_address
    # if not any(peer[0] == str(ip) for ip in IP_WHITELIST):
    #     return await websocket.send({"error": "not allowed from this IP"})

    body = await websocket.recv()

    with tempfile.NamedTemporaryFile(suffix='.tar.zst') as tmp:
        tmp.write(body)
        tmp.flush()
        with tarfile.open(tmp.name, 'r:zst') as t:
            t.extractall('/data')
            try:
                subprocess.run(['ls', '/data'])
                exit(0)
            except:
                pass

    return await websocket.send({"status": "ok"})

IP_WHITELIST = [ipaddress.ip_address('94.131.174.106')]

start_server = websockets.serve(handle_socket, '0.0.0.0', 8222)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

