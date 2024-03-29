// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.

#include <Windows.h>
#include <WinHttp.h>
#include <stdio.h>
#include <time.h>

int __cdecl wmain()
{
    DWORD dwError = ERROR_SUCCESS;
    BOOL fStatus = FALSE;
    HINTERNET hSessionHandle = NULL;
    HINTERNET hConnectionHandle = NULL;
    HINTERNET hRequestHandle = NULL;
    HINTERNET hWebSocketHandle = NULL;
    BYTE rgbCloseReasonBuffer[123];
    BYTE rgbBuffer[MAXBYTE];
    DWORD dwBufferLength = ARRAYSIZE(rgbBuffer);
    DWORD dwBytesTransferred = 0;
    DWORD dwCloseReasonLength = 0;
    USHORT usStatus = 0;
    WINHTTP_WEB_SOCKET_BUFFER_TYPE eBufferType;

    //
    // Create session, connection and request handles.
    //

	hSessionHandle = WinHttpOpen(L"WebSocket sample", WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, NULL, NULL, 0);

    if (hSessionHandle == NULL)
    {
        dwError = GetLastError();
        goto quit;
    }

	hConnectionHandle = WinHttpConnect(hSessionHandle, L"localhost", INTERNET_DEFAULT_HTTP_PORT, 0);

    if (hConnectionHandle == NULL)
    {
        dwError = GetLastError();
        goto quit;
    }

	hRequestHandle = WinHttpOpenRequest(hConnectionHandle, L"GET", L"/OPC/main.opc", NULL, NULL, NULL, 0);

    if (hRequestHandle == NULL)
    {
        dwError = GetLastError();
        goto quit;
    }

    //
    // Request protocol upgrade from http to websocket.
    //
#pragma prefast(suppress:6387, "WINHTTP_OPTION_UPGRADE_TO_WEB_SOCKET does not take any arguments.")

	fStatus = WinHttpSetOption(hRequestHandle, WINHTTP_OPTION_UPGRADE_TO_WEB_SOCKET, NULL, 0);

    if (!fStatus)
    {
        dwError = GetLastError();
        goto quit;
    }

    //
    // Perform websocket handshake by sending a request and receiving server's response.
    // Application may specify additional headers if needed.
    //

	fStatus = WinHttpSendRequest(hRequestHandle, WINHTTP_NO_ADDITIONAL_HEADERS, 0, NULL, 0, 0, 0);

    if (!fStatus)
    {
        dwError = GetLastError();
        goto quit;
    }

    fStatus = WinHttpReceiveResponse(hRequestHandle, 0);
    if (!fStatus)
    {
        dwError = GetLastError();
        goto quit;
    }

    //
    // Application should check what is the HTTP status code returned by the server and behave accordingly.
    // WinHttpWebSocketCompleteUpgrade will fail if the HTTP status code is different than 101.
    //

    hWebSocketHandle = WinHttpWebSocketCompleteUpgrade(hRequestHandle, NULL);
    if (hWebSocketHandle == NULL)
    {
        dwError = GetLastError();
        goto quit;
    }

    //
    // The request handle is not needed anymore. From now on we will use the websocket handle.
    //

    WinHttpCloseHandle(hRequestHandle);
    hRequestHandle = NULL;

	int count = 0;

	do
    {
		dwError = WinHttpWebSocketReceive(hWebSocketHandle, rgbBuffer, dwBufferLength, &dwBytesTransferred, &eBufferType);

        if (dwError != ERROR_SUCCESS)
        {
            break;
        }
		
		wprintf(L"%.*S", dwBytesTransferred, rgbBuffer);
		
        if (dwBytesTransferred < sizeof rgbBuffer) {
            wprintf(L"\n");

            if (count == 1) {

                printf("\nBrowse result:\n\n");

                char browse[] = "browse: Random";
                dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)browse, (DWORD)strlen(browse));

                if (dwError != ERROR_SUCCESS)
                {
                    break;
                }
            }
            else if (count == 2) {

                printf("\nHDA result:\n\n");
		SYSTEMTIME st;
                GetSystemTime(&st); 

                time_t start = time(NULL) - 2;
                time_t end = time(NULL);
                char command[MAXBYTE] = { NULL };
		sprintf_s(command, "readRaw: Random.Int1, Random.Int2 -%lld -%lld", start * 1000 + st.wMilliseconds, end * 1000 + st.wMilliseconds);

                dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)command, (DWORD)strlen(command));

                if (dwError != ERROR_SUCCESS)
                {
                    break;
                }
            }
            else if (count == 3) {

                printf("\nAE result:\n\n");

                char command[] = "subscribeAE";
                dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)command, (DWORD)strlen(command));

                if (dwError != ERROR_SUCCESS)
                {
                    break;
                }
            }
            else if (count == 4) {

                printf("\nDA result:\n\n");

                char command[] = "subscribe: Random.Int1, Random.Int2";
                dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)command, (DWORD)strlen(command));

                if (dwError != ERROR_SUCCESS)
                {
                    break;
                }
            }
            else
                if (count > 8)
                    break;

            if (dwBytesTransferred < sizeof rgbBuffer)
                ++count;
        }
	} while (true);

    //
    // Gracefully close the connection.
    //

	dwError = WinHttpWebSocketClose(hWebSocketHandle, WINHTTP_WEB_SOCKET_SUCCESS_CLOSE_STATUS, NULL, 0);

    if (dwError != ERROR_SUCCESS)
    {
        goto quit;
    }

    //
    // Check close status returned by the server.
    //

	dwError = WinHttpWebSocketQueryCloseStatus(hWebSocketHandle, &usStatus, rgbCloseReasonBuffer, ARRAYSIZE(rgbCloseReasonBuffer), &dwCloseReasonLength);
    if (dwError != ERROR_SUCCESS)
    {
        goto quit;
    }

	wprintf(L"The server closed the connection with status code: '%d' and reason: '%.*S'\n", (int)usStatus, dwCloseReasonLength, rgbCloseReasonBuffer);

quit:

    if (hRequestHandle != NULL)
    {
        WinHttpCloseHandle(hRequestHandle);
        hRequestHandle = NULL;
    }

    if (hWebSocketHandle != NULL)
    {
        WinHttpCloseHandle(hWebSocketHandle);
        hWebSocketHandle = NULL;
    }

    if (hConnectionHandle != NULL)
    {
        WinHttpCloseHandle(hConnectionHandle);
        hConnectionHandle = NULL;
    }

    if (hSessionHandle != NULL)
    {
        WinHttpCloseHandle(hSessionHandle);
        hSessionHandle = NULL;
    }

    if (dwError != ERROR_SUCCESS)
    {
        wprintf(L"Application failed with error: %u\n", dwError);
        return -1;
    }

    return 0;
}
