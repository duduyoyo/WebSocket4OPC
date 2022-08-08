// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
//
// Copyright (c) Microsoft Corporation. All rights reserved

/*
    This is important to display Chinese in console in an English OS. Set mode as below to tell console incoming is _O_WTEXT/_O_U16TEXT/_O_U8TEXT stream.
    To feed that stream wprintf() with correct WCHAR string must be provided. Use wprintf("%s") rather than wprintf("%S") since later one treats WCHAR as byte.
    In console property choose NSimSun font type since it contains required glyph to display Chinese correctly. This font will require decode from
    _O_WTEXT/_O_U16TEXT/_O_U8TEXT to code page 936, and set console code page from 437 (OEM English) to 936 (ANSI/OEM Simplified Chinese GBK).
    No need to use setlocale() and SetConsoleOutputCP()
 */

#include <Windows.h>
#include <WinHttp.h>
#include <stdio.h>

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


  /*  byte test[3] = { 0x8a,0x80,0x0d };

    char a[MAXBYTE] = { NULL };
    char raw[MAXBYTE] = { NULL };

    for (size_t i = 0; i < 3; i++)
    {
        char temp[3] = { NULL };
        sprintf_s(temp, "%02X", test[i]);
		strcat_s(raw, 3 * 2 + 1, temp);
    }

    sprintf(a, "%x%x%x", test[0], test[1], test[2]);*/

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

    //char subscribe[] = "browse";
   /* char subscribe[] = "subscribe: Random.Int1";
    dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)subscribe, (DWORD)strlen(subscribe));

    if (dwError != ERROR_SUCCESS)
    {
        goto quit;
    }*/

    //Sleep(1000);
    //char browse[] = "subscribe: Random.Int1";
   /* char browse[] = "browse";
    dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)browse, (DWORD)strlen(browse));

    if (dwError != ERROR_SUCCESS)
    {
        goto quit;
    }*/

	int count = 0;

	do
    {
        if (dwBufferLength == 0)
        {
            dwError = ERROR_NOT_ENOUGH_MEMORY;
			break;
        }

		dwError = WinHttpWebSocketReceive(hWebSocketHandle, rgbBuffer, dwBufferLength, &dwBytesTransferred, &eBufferType);

        if (dwError != ERROR_SUCCESS)
        {
            break;
        }
		
		wprintf(L"%.*S", dwBytesTransferred, rgbBuffer);
		
		if (dwBytesTransferred < sizeof rgbBuffer)
			wprintf(L"\n"); 

		if (count == 1) {
			char browse[] = "browse";
			dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)browse, (DWORD)strlen(browse));

			if (dwError != ERROR_SUCCESS)
			{
				break;
			}
		}
		else if (count == 2) {
			char subscribe[] = "subscribe: Random.Int1";
			dwError = WinHttpWebSocketSend(hWebSocketHandle, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, (PVOID)subscribe, (DWORD)strlen(subscribe));

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
