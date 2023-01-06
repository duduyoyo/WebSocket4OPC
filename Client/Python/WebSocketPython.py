import asyncio
import websockets
import time

async def main():
    async with websockets.connect("ws://localhost/OPC/main.opc") as ws:
        i = 0
        while ws.open == True:
            message = await ws.recv()
            print(f"{message}")

            if i == 1:
                print("\nBrowse result:\n")
                await ws.send("browse: Random")
            elif i == 2:
                print("\nHDA result:\n")
                start = round(time.time() * 1000) - 2000
                end = round(time.time() * 1000)
                command = "readRaw: Random.Int1, Random.Int2 -" + str(start) + " -" + str(end)
                await ws.send(command)
            elif i == 3:
                print("\nAE result:\n")
                await ws.send("subscribeAE")
            elif i == 4:
                print("\nDA result:\n")
                await ws.send("subscribe: Random.Int1, Random.Int2")
            if i == 8:
                break
            
            i += 1

asyncio.run(main())
