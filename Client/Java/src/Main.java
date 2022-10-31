import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletionStage;

public class Main {

	public static void main(String[] args) throws Exception {

		WebSocket ws = HttpClient.newHttpClient().newWebSocketBuilder()
				.buildAsync(URI.create("ws://localhost/OPC/main.opc"), new WebSocketClient()).join();
	
		System.out.println("\nBrowse Result\n");
		ws.sendText("browse: Random", true);
		
		Thread.sleep(1000);
		System.out.println("\nHDA Result\n");
		long start = System.currentTimeMillis() / 1000 - 60;
		long end = System.currentTimeMillis() / 1000;
		ws.sendText("readRaw:Random.Int1, Random.Int2 -" + start + " -" + end, true);
				
		Thread.sleep(1000);
		System.out.println("\nAE Result\n");
		ws.sendText("subscribeAE", true);
		
		
		int count = 0;

		while (count < 15) {
			Thread.sleep(1000);
			++count;
		}
		
		ws.sendText("unsubscribeAE", true);
		
		Thread.sleep(1000);
		System.out.println("\nDA Result\n");
		ws.sendText("subscribe:Random.Int1, Random.Int2", true);
		
		count = 0;
		while (count < 4) {
			Thread.sleep(1000);
			++count;
		}
		
		ws.sendClose(WebSocket.NORMAL_CLOSURE, "");
	}

	private static class WebSocketClient implements WebSocket.Listener {

		private StringBuilder builder = new StringBuilder();

		@Override
		public void onOpen(WebSocket webSocket) {
			WebSocket.Listener.super.onOpen(webSocket);
		}

		@Override
		public CompletionStage<?> onText(WebSocket webSocket, CharSequence data, boolean last) {

			builder.append(data);
			if (last) {
				System.out.println(builder);
				builder = new StringBuilder();
			} else {
				webSocket.request(1);
			}

			return WebSocket.Listener.super.onText(webSocket, data, last);
		}

		@Override
		public void onError(WebSocket webSocket, Throwable error) {
			System.out.println("Bad day! " + webSocket.toString());
			WebSocket.Listener.super.onError(webSocket, error);
		}
	}
}