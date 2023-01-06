using System;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace WebSocketSharp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            using (var ws = new ClientWebSocket())
            {
                await ws.ConnectAsync(new Uri("ws://localhost/OPC/main.opc"), CancellationToken.None);
                byte[] buffer = new byte[byte.MaxValue];
                var count = 0;

                while (ws.State == WebSocketState.Open)
                {
                    WebSocketReceiveResult result = null;

                    do
                    {
                        result = await ws.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

                        Console.Write(System.Text.Encoding.UTF8.GetString(buffer, 0, result.Count));

                    } while (!result.EndOfMessage);

                    Console.WriteLine();

                    if (count == 1)
                    {
                        Console.WriteLine("\nBrowse result:\n");
                        await ws.SendAsync(new ArraySegment<byte>(Encoding.UTF8.GetBytes("browse: Random")), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                    else if (count == 2)
                    {
                        Console.WriteLine("\nHDA result:\n");
                        long start = DateTimeOffset.Now.ToUnixTimeMilliseconds() - 20;
                        long end = DateTimeOffset.Now.ToUnixTimeMilliseconds();
                        String command = "readRaw: Random.Int1, Random.Int2 -" + start + " -" + end;
                        await ws.SendAsync(new ArraySegment<byte>(Encoding.UTF8.GetBytes(command)), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                    else if (count == 3)
                    {
                        Console.WriteLine("\nAE result:\n");
                        await ws.SendAsync(new ArraySegment<byte>(Encoding.UTF8.GetBytes("subscribeAE")), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                    else if (count == 4)
                    {
                        Console.WriteLine("\nDA result:\n");
                        await ws.SendAsync(new ArraySegment<byte>(Encoding.UTF8.GetBytes("subscribe:Random.Int1, Random.Int2")), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                    else if (count > 6)
                        await ws.CloseOutputAsync(WebSocketCloseStatus.NormalClosure, "I am closing", CancellationToken.None);

                    count++;
                }
            }
        }
    }
}
