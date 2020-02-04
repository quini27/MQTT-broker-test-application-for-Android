(*****************************************************************************)
{    Project Android MQTT broker test
    Android Application to test a connection with a MQTT Broker
    There must be chosen a free MQTT broker, as
    "test.mosquitto.org"; //"broker.hivemq.com";  //"iot.eclipse.com";
    //"mqtt.fluux.io"; //"test.mosca.io"; //"broker.mqttdashboard.com";,
    and the port is the open MQTT port 1883
    To test this application the sketch test_eclipse.ino must be previously stored on the IoT board.
    The topics that the IoT board publishes are Estado/Led, Estado/Botao and TopicIoTboard71,
    and its subscribes to the topic MessFromClient71.
    According to the message sent from this application, the IoT board put on/off the led, returns the button state,
    and prints the request on the serial monitor.  }
    //      Copyright: Fernando Pazos
    //      december 2019
(*****************************************************************************)






unit HeaderFooterTemplate;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  TMS.MQTT.Global, FMX.Edit, FMX.ScrollBox, FMX.Memo, FMX.ListBox,
  TMS.MQTT.Client, FMX.Objects, FMX.Controls.Presentation;

type
  TMainForm = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    Circle1: TCircle;
    led: TCircle;
    Label1: TLabel;
    TMSMQTTClient1: TTMSMQTTClient;
    brokerLbl: TLabel;
    portLbl: TLabel;
    BrokerList: TComboBox;
    MemoLog: TMemo;
    Edit1: TEdit;
    SendBtn: TButton;
    Label2: TLabel;
    ConnectBtn: TSpeedButton;
    DisconnectBtn: TSpeedButton;
    procedure BrokerListChange(Sender: TObject);
    procedure ConnectBtnClick(Sender: TObject);
    procedure DisconnectBtnClick(Sender: TObject);
    procedure MemoLogChange(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
    procedure TMSMQTTClient1ConnectedStatusChanged(ASender: TObject;
      const AConnected: Boolean; AStatus: TTMSMQTTConnectionStatus);
    procedure TMSMQTTClient1PublishReceived(ASender: TObject; APacketID: Word;
      ATopic: string; APayload: TArray<System.Byte>);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.SmXhdpiPh.fmx ANDROID}
{$R *.Surface.fmx MSWINDOWS}
{$R *.SSW3.fmx ANDROID}

//event executed when a broker URL is selected from the list box
procedure TMainForm.BrokerListChange(Sender: TObject);
var LIndex:integer;
begin
  LIndex:=BrokerList.ItemIndex;
  TMSMQTTClient1.BrokerHostName:=BrokerList.Items[LIndex];
end;

//Event executed when the Connect button is pressed
procedure TMainForm.ConnectBtnClick(Sender: TObject);
begin
    TMSMQTTClient1.Connect();
end;

//Event executed when the disconnect button os pressed
procedure TMainForm.DisconnectBtnClick(Sender: TObject);
begin
    TMSMQTTClient1.Disconnect();
end;

//EVENT executed when MemoLog is on change to scroll the memoLog until the last row
procedure TMainForm.MemoLogChange(Sender: TObject);
begin
   //SendMessage(MemoLog.Handle, EM_LINESCROLL, 0,MemoLog.Lines.Count);
end;

//Event executed when the Send button os pressed
procedure TMainForm.SendBtnClick(Sender: TObject);
begin
   if Edit1.Text<>'' then
     begin
        TMSMQTTClient1.Publish('MessFromClient71',Edit1.Text);
        Edit1.Text:='';
     end;
end;

//Event executed when the Connection state changes
//It toggles the connect and disconnect enabled status, and put on/off the drawn led
//prints on the memo log window the connection status.
//when connected, subscribes to the topics Estado/Led, Estado/Botao and TopicIoTboard71
procedure TMainForm.TMSMQTTClient1ConnectedStatusChanged(ASender: TObject;
  const AConnected: Boolean; AStatus: TTMSMQTTConnectionStatus);
begin
    if (AConnected) then
      begin
        ConnectBtn.Enabled:=False;
        BrokerList.Enabled:=False;
        SendBtn.Enabled:=True;
        DisconnectBtn.Enabled:=True;
        Edit1.Enabled:=True;
        TMSMQTTClient1.Subscribe('Estado/Led');
        TMSMQTTClient1.Subscribe('Estado/Botao');
        TMSMQTTClient1.Subscribe('TopicIoTboard71');
        TMSMQTTClient1.Subscribe('AnalogInput');
        Led.Fill.Color:=$FFFF0000;             //led color=red
        MemoLog.Lines.Add('Client connected to server '+#13#10+TMSMQTTClient1.BrokerHostName+' at '+FormatDateTime('hh:nn:ss', Now));
      end
      else
      begin
        ConnectBtn.Enabled:=True;
        BrokerList.Enabled:=True;
        SendBtn.Enabled:=False;
        DisconnectBtn.Enabled:=False;
        Edit1.Enabled:=False;
        Led.Fill.Color:=$FF800000;     //led color=maroon
        MemoLog.Lines.Add('Client disconnected from server '+#13#10+TMSMQTTClient1.BrokerHostName+' at '+FormatDateTime('hh:nn:ss', Now));
        case AStatus of
          csNotConnected: MemoLog.Lines.Add('Client not connected');
          //csConnectionRejected_InvalidProtocolVersion: ;
          //csConnectionRejected_InvalidIdentifier: ;
          csConnectionRejected_ServerUnavailable: MemoLog.Lines.Add('Server Unavailable');
          //csConnectionRejected_InvalidCredentials: ;
          csConnectionRejected_ClientNotAuthorized: MemoLog.Lines.Add('Client not authorized');
          csConnectionLost: MemoLog.Lines.Add('Connection lost');
          //csConnecting: ;
          //csReconnecting: ;
          //csConnected: ;
        end;
      end;
end;


//Event executed when a message is received from the publisher (IoT board)
//It prints the received message on the Memo Log window
procedure TMainForm.TMSMQTTClient1PublishReceived(ASender: TObject;
  APacketID: Word; ATopic: string; APayload: TArray<System.Byte>);
var msg:string;
begin
  msg := TEncoding.UTF8.GetString(APayload);
  MemoLog.Lines.Add('Message received from the publisher'+#13#10+'['+ATopic+']: '+msg);
end;

end.
