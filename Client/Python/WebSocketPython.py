import asyncio
import websockets

async def main():
    async with websockets.connect("ws://localhost/OPC/main.opc") as ws:
        i = 0
        while ws.open == True:
            message = await ws.recv()
            print(f"{message}")

            if i == 1:
                await ws.send("browse")
            elif i == 2:
                await ws.send("subscribe: Random.Int1")
            if i == 8:
                break
            
            i += 1

asyncio.run(main())
