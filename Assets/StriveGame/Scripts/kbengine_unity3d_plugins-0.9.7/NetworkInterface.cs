namespace KBEngine
{
  	using UnityEngine; 
	using System; 
	using System.Net.Sockets; 
	using System.Net; 
	using System.Collections; 
	using System.Collections.Generic;
	using System.Text;
	using System.Text.RegularExpressions;
	using System.Threading;
	
	using MessageID = System.UInt16;
	using MessageLength = System.UInt16;
	
	/*
		网络模块
		处理连接、收发数据
	*/
    public class NetworkInterface 
    {
    	public const int TCP_PACKET_MAX = 1460;
        public static int RECV_BUFFER_MAX = 1460;
        public static int SEND_BUFFER_MAX = 1460;
    	public delegate void ConnectCallback(string ip, int port, bool success, object userData);
    	
        Socket _socket = null;
		PacketReceiver _packetReceiver = null;
		PacketSender _packetSender = null;
		
		public class ConnectState
		{
			// for connect
			public string connectIP = "";
			public int connectPort = 0;
			public ConnectCallback connectCB = null;
			public object userData = null;
			public Socket socket = null;
			public NetworkInterface networkInterface = null;
			public string error = "";
		}
		
        public NetworkInterface()
        {
        	reset();
        }
		
		public void reset()
		{
			if(valid())
			{
         	   _socket.Close(0);
			}
			_socket = null;
			_packetReceiver = null;
			_packetSender = null;
		}
		
		public Socket sock()
		{
			return _socket;
		}
		
		public PacketReceiver packetReceiver()
		{
			return _packetReceiver;
		}
		
		public bool valid()
		{
			return ((_socket != null) && (_socket.Connected == true));
		}
		
		public void _onConnectStatus(ConnectState state)
		{
			KBEngine.Event.deregisterIn(this);
			
			bool success = (state.error == "" && valid());
			if(success)
			{
				Dbg.DEBUG_MSG(string.Format("NetworkInterface::_onConnectStatus(), connect to {0} is success!", state.socket.RemoteEndPoint.ToString()));
				_packetReceiver = new PacketReceiver(this);
				_packetReceiver.startRecv();
			}
			else
			{
				Dbg.ERROR_MSG(string.Format("NetworkInterface::_onConnectStatus(), connect is error! ip: {0}:{1}, err: {2}", state.connectIP, state.connectPort, state.error));
			}

            LuaFramework.Util.CallMethod("Event", "Brocast", new object[] { "onConnectStatus", success });
			//Event.fireOut("onConnectStatus", new object[]{success});
			
			if (state.connectCB != null)
				state.connectCB(state.connectIP, state.connectPort, success, state.userData);
		}
		
		private static void connectCB(IAsyncResult ar)
		{
			ConnectState state = null;
			
			try 
			{
				// Retrieve the socket from the state object.
				state = (ConnectState) ar.AsyncState;

				// Complete the connection.
				state.socket.EndConnect(ar);

				Event.fireIn("_onConnectStatus", new object[]{state});
			} 
			catch (Exception e) 
			{
				state.error = e.ToString();
				Event.fireIn("_onConnectStatus", new object[]{state});
			}
		}
	    
		public void connectTo(string ip, int port, ConnectCallback callback, object userData) 
		{
			if (valid())
				throw new InvalidOperationException( "Have already connected!" );
			
			if(!(new Regex( @"((?:(?:25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(?:25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d))))")).IsMatch(ip))
			{
				IPHostEntry ipHost = Dns.GetHostEntry (ip);
				ip = ipHost.AddressList[0].ToString();
			}

			// Security.PrefetchSocketPolicy(ip, 843);
            IPAddress[] hostAddresses = Dns.GetHostAddresses(ip);
            IPAddress[] outIPs = hostAddresses;
            AddressFamily addressFamily = AddressFamily.InterNetwork;
            if (Socket.OSSupportsIPv6 && this.IsHaveIpV6Address(hostAddresses, ref outIPs))
            {
                addressFamily = AddressFamily.InterNetworkV6;
            }
            _socket = new Socket(addressFamily, SocketType.Stream, ProtocolType.Tcp);
            _socket.SetSocketOption(System.Net.Sockets.SocketOptionLevel.Socket, SocketOptionName.ReceiveBuffer, NetworkInterface.RECV_BUFFER_MAX * 2);
			
			ConnectState state = new ConnectState();
			state.connectIP = ip;
			state.connectPort = port;
			state.connectCB = callback;
			state.userData = userData;
			state.socket = _socket;
			state.networkInterface = this;
			
			Dbg.DEBUG_MSG("connect to " + ip + ":" + port + " ...");
			
			// 先注册一个事件回调，该事件在当前线程触发
			Event.registerIn("_onConnectStatus", this, "_onConnectStatus");
			
			try 
			{ 
				_socket.BeginConnect(new IPEndPoint(IPAddress.Parse(ip), port), new AsyncCallback(connectCB), state);
            } 
            catch (Exception e) 
            {
            	state.error = e.ToString();
				Event.fireIn("_onConnectStatus", new object[]{state});
            }
		}

        private bool IsHaveIpV6Address(IPAddress[] IPs, ref IPAddress[] outIPs)
        {
            int length = 0;
            for (int index = 0; index < IPs.Length; ++index)
            {
                if (AddressFamily.InterNetworkV6.Equals((object)IPs[index].AddressFamily))
                    ++length;
            }
            if (length <= 0)
                return false;
            outIPs = new IPAddress[length];
            int num = 0;
            for (int index = 0; index < IPs.Length; ++index)
            {
                if (AddressFamily.InterNetworkV6.Equals((object)IPs[index].AddressFamily))
                    outIPs[num++] = IPs[index];
            }
            return true;
        }

        public void close()
        {
           if(_socket != null)
			{
				_socket.Close(0);
				_socket = null;
				Event.fireAll("onDisableConnect", new object[]{});
            }

            _socket = null;
        }

		public bool send(MemoryStream stream)
		{
			if (!valid())
			{
				throw new ArgumentException("invalid socket!");
			}

			if (_packetSender == null)
				_packetSender = new PacketSender(this);

			return _packetSender.send(stream);
		}

		public void process()
		{
			if (!valid())
				return;

			if (_packetReceiver != null)
				_packetReceiver.process();
		}
	}
}
