'Free basic Address Event Representation

#include once "libusb-1.0.bi"
#include once "hidlib.bas"
#include once "HID_info.bas"
#include once "comlinepar.bas"

counter = 0

For i as integer = 0 To 63
	databuffer(i) = 100+i
Next i

'#include once "caerdeviceinfo.bas"


returnvalue = libusb_init(NULL)
If returnvalue < 0 Then
   End returnvalue
End If

cnt = libusb_get_device_list(NULL, @ppList)
If (cnt < 0) then
    End cnt
End if

'? "Found ";cnt ;" usb devices"
'?
? "Looking for "; Hex(Vendor,4); ":"; Hex(Product,4)
?

for i as integer = 0 to cnt-1
    pDevice = ppList[i]
    returnvalue = libusb_get_device_descriptor(pDevice, @desc) 
    '? Hex(desc.idVendor,4); ":"; Hex(desc.idProduct,4)
    If Hex(desc.idVendor,4) = Hex(Vendor,4) And Hex(desc.idProduct,4) = Hex(Product,4) Then
		?
		? "Found the device    "; pDevice
		DHandle(counter) = open_device(pDevice)
		
		returnvalue = print_device_descriptor(desc, sup_out)
		returnvalue = print_vendor_info(DHandle(counter), desc, 0)
		
		returnvalue = libusb_get_config_descriptor(pDevice, 0, @Dconfig)
		If returnvalue = 0 Then
			returnvalue = print_config_descriptor(Dconfig, sup_out)			
		    For ii as integer = 0 To Dconfig->bNumInterfaces - 1
				inter = @Dconfig->interface[ii]
				Print "Number of alternate settings: ";inter->num_altsetting
				For j as integer = 0 To inter->num_altsetting - 1
					interdesc = @inter->altsetting[j]
					returnvalue = print_interface_descriptor(interdesc, sup_out)
					returnvalue = print_interface_info(DHandle(counter), interdesc, sup_out)
					? "number of endpoints: "; interdesc->bNumEndpoints
					For k as integer = 0 To interdesc->bNumEndpoints - 1
						epdesc = @interdesc->endpoint[k]
						returnvalue = print_endpoint_descriptor(epdesc, sup_out)
						if (sup_out = 0) then 
							? ii;" ";j;" ";k
						End If
						If (epdesc->bEndpointAddress >= 128) then
							in_endpoint(in_cnt) = epdesc->bEndpointAddress
							in_packsize(in_cnt) = epdesc->wMaxPacketSize
							in_cnt = in_cnt + 1
						End if
						If (epdesc->bEndpointAddress < 128) then
							out_endpoint(out_cnt) = epdesc->bEndpointAddress
							out_packsize(out_cnt) = epdesc->wMaxPacketSize
							out_cnt = out_cnt + 1
						End if
						If (sup_out = 0) then
							? "ep address "; epdesc->bEndpointAddress
							? "in "; in_endpoint(in_cnt)
							? "out "; out_endpoint(out_cnt)
						End If
					Next k
				Next j
			Next ii			
		Else
			? "Error getting config descriptor"
			End returnvalue
		End IF
		
		counter = counter + 1
	
    End If
next i

? "number of attached devices "; counter
?

If (counter>0) then



	Print "press Esc to quit"
	
	? "in endpoint 0: "; in_endpoint(0)
	? "in endpoint 1: "; in_endpoint(1)
	? "out endpoint 0: "; out_endpoint(0)
	? "out endpoint 1: "; out_endpoint(1)
	
	countbytes = 0
	
	Do
	
		returnvalues = bulk_tranfer(DHandle(counter-1), in_endpoint(0), dbuf, in_packsize(0), 1, 0)
		If (returnvalues.B = -4) then 
			Exit Do
		End If
		If (returnvalues.B <> -7) then
			If (returnvalues.A>0) then
				'? returnvalues.A; " bytes received"
				'? "aantal * "; returnvalues.A; " = "; countbytes
				countbytes = countbytes + returnvalues.A
				For ii as integer = 0 To returnvalues.A - 1 Step 4
					if (databuffer(ii) <> databuffer_oud1) or (databuffer(ii+1) <> databuffer_oud2) or (databuffer(ii+2) <> databuffer_oud3) or (databuffer(ii+3) <> databuffer_oud4 )then 
						? databuffer(ii); ", "; databuffer(ii+1); ", "; databuffer(ii+2); ", "; databuffer(ii+3); ", " 
					End If
					databuffer_oud1 = databuffer(ii)
					databuffer_oud2 = databuffer(ii+1)
					databuffer_oud3 = databuffer(ii+2)
					databuffer_oud4 = databuffer(ii+3)
				Next ii
			'?
			'? "packet nr."; 256*databuffer(62)+databuffer(63)
			End If
		End If
		key = Inkey
		If (key <> "") then
			? countbytes
		'	? "key pressed: "; asc(key)
		'	databuffer(0) = asc(key)
		'	returnvalues = transfer_data(DHandle(counter-1), out_endpoint(0), dbuf, out_packsize(0), 100, 100)
		End If

	Loop Until key = chr$(27)
	
	returnvalue = close_device(DHandle(counter-1))
End If


returnvalue = exit_prog(ppList)

sleep

