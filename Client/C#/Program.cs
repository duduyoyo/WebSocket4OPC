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
                byte[] buffer = new byte[256];
                var count = 0;

                while (ws.State == WebSocketState.Open)
                {
                    WebSocketReceiveResult result = null;

                    do
                    {
                        result = await ws.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

                        Console.WriteLine(System.Text.Encoding.UTF8.GetString(buffer, 0, result.Count));

                    } while (!result.EndOfMessage);

                    if (count == 1) {
                        await ws.SendAsync(new ArraySegment<byte>(Encoding.UTF8.GetBytes("browse")), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                    else if (count == 2)
                        await ws.SendAsync(new ArraySegment<byte>(Encoding.UTF8.GetBytes("subscribe:Random.Int1")), WebSocketMessageType.Text, true, CancellationToken.None);
                    else if (count > 8)
                        await ws.CloseOutputAsync(WebSocketCloseStatus.NormalClosure, "I am closing", CancellationToken.None);

                    count++;
                }
            }
        }
    }
}
