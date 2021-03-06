﻿<%--
    Myrtille: A native HTML4/5 Remote Desktop Protocol client.

    Copyright(c) 2014-2017 Cedric Coste

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

	    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
--%>

<%@ Page Language="C#" Inherits="Myrtille.Web.Default" Codebehind="Default.aspx.cs" AutoEventWireup="true" Culture="auto" UICulture="auto" %>
<%@ OutputCache Location="None" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="Myrtille.Web" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
	
    <head>

        <!-- force IE out of compatibility mode -->
        <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1"/>

        <!-- mobile devices -->
        <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0"/>
        
        <title>Myrtille</title>
        
        <link rel="icon" type="image/png" href="img/myrtille.png"/>
        <link rel="stylesheet" type="text/css" href="css/Default.css"/>

        <script language="javascript" type="text/javascript" src="js/myrtille.js"></script>
        <script language="javascript" type="text/javascript" src="js/config.js"></script>
        <script language="javascript" type="text/javascript" src="js/dialog.js"></script>
        <script language="javascript" type="text/javascript" src="js/display.js"></script>
        <script language="javascript" type="text/javascript" src="js/display/canvas.js"></script>
        <script language="javascript" type="text/javascript" src="js/display/divs.js"></script>
        <script language="javascript" type="text/javascript" src="js/network.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/buffer.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/longpolling.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/websocket.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/xmlhttp.js"></script>
        <script language="javascript" type="text/javascript" src="js/user.js"></script>
        <script language="javascript" type="text/javascript" src="js/user/keyboard.js"></script>
        <script language="javascript" type="text/javascript" src="js/user/mouse.js"></script>
        <script language="javascript" type="text/javascript" src="js/user/touchscreen.js"></script>

	</head>
	
    <body onload="startMyrtille(
        <%=(RemoteSession != null && (RemoteSession.State == RemoteSessionState.Connecting || RemoteSession.State == RemoteSessionState.Connected)).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.StatMode).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.DebugMode).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.CompatibilityMode).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.ScaleDisplay).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null ? RemoteSession.ClientWidth.ToString() : "null")%>,
        <%=(RemoteSession != null ? RemoteSession.ClientHeight.ToString() : "null")%>);">

        <!-- custom UI: all elements below, including the logo, are customizable into Default.css -->

        <form method="post" runat="server" id="mainForm">

            <!-- LOGIN -->
            <div runat="server" id="loginScreen">

                <!-- customizable logo -->
                <div runat="server" id="logo"></div>

                <!-- server -->
                <div class="inputDiv">
                    <label runat="server" id="serverLabel" for="server">Server (:port)</label>
                    <input type="text" runat="server" id="server" title="server address or hostname (:port, if other than the standard 3389)"/>
                </div>

                <!-- domain -->
                <div class="inputDiv">
                    <label runat="server" id="domainLabel" for="domain">Domain (optional)</label>
                    <input type="text" runat="server" id="domain" title="user domain (if applicable)"/>
                </div>
                
                <!-- user -->
                <div class="inputDiv">
                    <label runat="server" id="userLabel" for="user">User</label>
                    <input type="text" runat="server" id="user" title="user name"/>
                </div>

                <!-- password -->
                <div class="inputDiv">
                    <label runat="server" id="passwordLabel" for="password">Password</label>
                    <input type="password" runat="server" id="password" title="user password"/>
                </div>

                <!-- program to run -->
                <div class="inputDiv">
                    <label runat="server" id="programLabel" for="program">Program to run (optional)</label>
                    <input type="text" runat="server" id="program" title="executable path, name and parameters (double quotes must be escaped) (optional)"/>
                </div>

                <!-- display resolution -->
                <input type="hidden" runat="server" id="width"/>
                <input type="hidden" runat="server" id="height"/>
                
                <!-- connect -->
                <input type="submit" runat="server" id="connect" value="Connect!" onclick="showToolbar();" onserverclick="ConnectButtonClick" title="open session"/>

                <!-- myrtille version -->
                <div id="version">
                    <a href="http://cedrozor.github.io/myrtille/">
                        <img src="img/myrtille.png" alt="myrtille" width="15px" height="15px"/>
                    </a>
                    <span>
                        <%=typeof(Default).Assembly.GetName().Version%>
                    </span>
                </div>
                
            </div>

            <!-- TOOLBAR -->
            <div runat="server" id="toolbar" style="visibility:hidden;display:none;">

                <!-- server info -->
                <input type="text" runat="server" id="serverInfo" title="connected server" disabled="disabled"/>

                <!-- stat bar -->
                <input type="button" runat="server" id="stat" value="Show Stat" onclick="toggleStatMode();" title="display network and rendering info" disabled="disabled"/>

                <!-- debug log -->
                <input type="button" runat="server" id="debug" value="Show Debug" onclick="toggleDebugMode();" title="display debug info" disabled="disabled"/>

                <!-- browser mode -->
                <input type="button" runat="server" id="browser" value="HTML4" onclick="toggleCompatibilityMode();" title="rendering mode" disabled="disabled"/>

                <!-- scale display -->
                <input type="button" runat="server" id="scale" value="Scale" onclick="toggleScaleDisplay();" title="dynamically scale the remote session display to the browser size (responsive design)" disabled="disabled"/>

                <!-- virtual keyboard. on devices without a physical keyboard, forces the device virtual keyboard to pop up -->
                <input type="button" runat="server" id="keyboard" value="Keyboard" onclick="openPopup('virtualKeyboardPopup', 'VirtualKeyboard.aspx');" title="send text to the remote session (tip: can be used to send the local clipboard content (text only))" disabled="disabled"/>

                <!-- remote clipboard. display the remote clipboard content and allow to copy it locally (text only) -->
                <input type="button" runat="server" id="clipboard" value="Clipboard" onclick="requestRemoteClipboard();" title="retrieve the remote clipboard content (text only)" disabled="disabled"/>

                <!-- upload/download file(s). only enabled if the connected server is localhost or if a domain is specified (so file(s) can be accessed within the rdp session) -->
                <input type="button" runat="server" id="files" value="Files" onclick="openPopup('fileStoragePopup', 'FileStorage.aspx');" title="upload/download files to/from the user documents folder" disabled="disabled"/>

                <!-- send ctrl+alt+del to the remote session. may be useful to change the user password, for example -->
                <input type="button" runat="server" id="cad" value="Ctrl+Alt+Del" onclick="sendCtrlAltDel();" title="send Ctrl+Alt+Del to the remote session" disabled="disabled"/>

                <!-- disconnect -->
                <input type="button" runat="server" id="disconnect" value="Disconnect" onserverclick="DisconnectButtonClick" title="close session" disabled="disabled"/>

            </div>

            <!-- remote session display -->
            <div id="displayDiv"></div>

            <!-- remote session helpers -->
            <div id="statDiv"></div>
		    <div id="debugDiv"></div>
            <div id="msgDiv"></div>
            <div id="kbhDiv"></div>
            <div id="bgfDiv"></div>

        </form>

        <script type="text/javascript" language="javascript" defer="defer">

            function showToolbar()
            {
                // server info
                var server = document.getElementById('<%=server.ClientID%>');
                if (server != null)
                {
                    var serverInfo = document.getElementById('<%=serverInfo.ClientID%>');
                    if (serverInfo != null)
                    {
                        serverInfo.value = server.value == '' ? 'localhost' : server.value;
                    }
                }

                // show toolbar
                var toolbar = document.getElementById('<%=toolbar.ClientID%>');
                if (toolbar != null)
                {
                    toolbar.style.visibility = 'visible';
                    toolbar.style.display = 'block';
                }

                /*
                CAUTION! on mobile devices, there isn't any reliable/standard way to detect the zoom level
                problem is, the browser size (used as remote session size) detection is impacted by the zoom level, if any
                disabling the zoom is also not possible on some devices (and not a good idea anyway, for the user experience)
                a workaround is to use the device pixel ratio, but it won't work on high DPI screens (disabled code below)
                in any case, using the page default zoom does work
                */

                //var browserZoomLevel = 100;

                //try
                //{
                //    browserZoomLevel = Math.round(window.devicePixelRatio * 100);
                //    alert('browser zoom level: ' + browserZoomLevel);
                //}
                //catch (exc)
                //{
                //    // not supported by the browser
                //}

                // browser size. default 1024x768
                var display = new Display();

                //alert('toolbar horizontal offset: ' + display.getHorizontalOffset() + ', vertical: ' + display.getVerticalOffset());

                //var width = ((display.getBrowserWidth() - display.getHorizontalOffset()) * browserZoomLevel / 100);
                //var height = ((display.getBrowserHeight() - display.getVerticalOffset()) * browserZoomLevel / 100);

                var width = display.getBrowserWidth() - display.getHorizontalOffset();
                var height = display.getBrowserHeight() - display.getVerticalOffset();

                //alert('client width: ' + width + ', height: ' + height);

                document.getElementById('<%=width.ClientID%>').value = width;
                document.getElementById('<%=height.ClientID%>').value = height;
            }

            function disableControl(controlId)
            {
                var control = document.getElementById(controlId);
                if (control != null)
                {
                    control.disabled = true;
                }
            }

            function disableToolbar()
            {
                disableControl('<%=stat.ClientID%>');
                disableControl('<%=debug.ClientID%>');
                disableControl('<%=browser.ClientID%>');
                disableControl('<%=scale.ClientID%>');
                disableControl('<%=keyboard.ClientID%>');
                disableControl('<%=clipboard.ClientID%>');
                disableControl('<%=files.ClientID%>');
                disableControl('<%=cad.ClientID%>');
                disableControl('<%=disconnect.ClientID%>');
            }

		</script>

	</body>

</html>