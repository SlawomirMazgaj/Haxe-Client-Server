package view;

import js.html.WebSocket;
import react.ReactComponent;
import react.ReactMacro.jsx;

class MainView extends ReactComponentOfState<MainViewState>
{
	private static var PORT : Int = 1234;

	private var _ws : WebSocket;


	public function new(props:Dynamic) 
	{
		super(props);
		
		state = {
			isConnected: false,
			messages: []
		};
	}

	override public function render():ReactElement 
	{
		if (state.isConnected == false)
		{
			// Show login component
			return jsx('
				<$LoginView connectHandler=${connectToServer} />
			');
		}
		else
		{
			// Show chat component
			return jsx('
				<div style={{height: "100vh", display: "flex", flexDirection: "column", justifyContent: "flex-end", backgroundColor: "#DDDDDD"}}>
					<$ChatView messages=${state.messages} />
					<div style = {{padding: 5, display: "flex"}}>
						<input ref="input" placeholder="Type text here" onKeyPress=$onKeyPress style={{flexGrow: 2}} />
						<button onClick=$sendMessage>Send</button>
					</div>
				<div/>
			');
		}
	}


	private function connectToServer( host : String ):Void
	{
		_ws = new WebSocket('ws://$host:$PORT');
		_ws.onopen = function()
		{
			trace("CONNECT");
			setState({ isConnected: true });
		};
		_ws.onmessage = function(e)
		{
			trace("RECEIVE: " + e.data);
			var messages:Array<String> = state.messages;
			messages.push(e.data);
			setState({ messages: messages });
		};
		_ws.onclose = function()
		{
			trace("DISCONNECT");
		};
	}

	private function onKeyPress(e:Dynamic)
	{
		if (e.key == 'Enter')
		{
			sendMessage();
		}
	}


	private function sendMessage()
	{
		var text:String = refs.input.value;
		if (text.length > 0) 
		{
			trace(text);
			_ws.send(text);
			refs.input.value = "";
		}
	}
}

typedef MainViewState = {
	?isConnected : Bool,
	?messages : Array<String>,
}