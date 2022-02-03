Type multireturn
    As long A,B,C
End Type

'dim as uinteger Vendor = &h154B
'dim as uinteger Product = &hF009
'dim shared as uinteger Vendor = &h152A
'dim as uinteger Product = &h841d
dim shared as uinteger Vendor = &h04B4 
dim as uinteger Product = &h00F1
'dim as uinteger Vendor = &h16C0
'dim as uinteger Product = &h0486
dim as libusb_device_handle ptr DHandle(10)
dim shared as libusb_device_descriptor desc
dim as libusb_transfer_cb_fn call_back 
dim as libusb_config_descriptor ptr Dconfig
dim as integer conf
dim as libusb_device ptr pDevice
dim as libusb_device ptr ptr ppList
dim as integer cnt = 0
dim as Long returnvalue
dim as Const libusb_interface Ptr inter
dim as Const libusb_interface_descriptor Ptr interdesc
dim shared as Const libusb_endpoint_descriptor Ptr epdesc
dim as libusb_transfer Ptr xfr
dim as uinteger size = 2048
dim as Ubyte databuffer(size)
dim as Ubyte databuffer_oud1 = 0
dim as Ubyte databuffer_oud2 = 0
dim as Ubyte databuffer_oud3 = 0
dim as Ubyte databuffer_oud4 = 0
dim as Ubyte ptr dbuf = @databuffer(0)
dim as Ubyte in_endpoint(10)
dim as uinteger in_packsize(10)
dim as Ubyte in_cnt = 0
dim as Ubyte out_cnt = 0
dim as Ubyte out_endpoint(10)
dim as uinteger out_packsize(10)
dim as Ubyte counter
dim as multireturn returnvalues
dim as String key
dim as uinteger countbytes = 0
dim as Ubyte sup_out = 1

Declare Function open_device(device as libusb_device ptr) as libusb_device_handle ptr
Declare Function close_device(handle as libusb_device_handle ptr) as long
Declare Function exit_prog(ppList as libusb_device ptr ptr) as long
Declare Function transfer_data(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn
Declare Function bulk_tranfer(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn

Function open_device(device as libusb_device ptr) as libusb_device_handle ptr
    dim as long returnvalue
    dim as libusb_device_handle ptr Handle
    
    returnvalue = libusb_open(device, @Handle)
    ? "dev_handle          "; Handle
    ? "Error Detail       "; returnvalue

    ? *(libusb_error_name(returnvalue))
        
    returnvalue = libusb_reset_device(Handle)
    ? "Error Reset Device "; returnvalue
    ?
        
    If Handle > 0 Then
        returnvalue = libusb_kernel_driver_active(Handle, 0)          ''check if kernel has attached a driver
        ? "Check attached     "; returnvalue
        If returnvalue > 0 Then                                        ''if so
            returnvalue = libusb_detach_kernel_driver(Handle, 0)      ''detach it
            ? "Detached           ";  returnvalue
        End If
        returnvalue = libusb_claim_interface(Handle, 0)               ''now we can claim the interface
        ? "Claim              ";  returnvalue
        ?
    End If
    return Handle
End Function

Function close_device(handle as libusb_device_handle ptr) as long
    dim as long returnvalue
    
    returnvalue = libusb_release_interface(handle, 0)
    ?
    ? "release :"; returnvalue
    libusb_close(handle)
    return returnvalue
End Function

Function exit_prog(ppList as libusb_device ptr ptr) as long
? "ok"
libusb_free_device_list(ppList, 1)
libusb_exit(NULL)
? "end"
return 1
End Function

Function print_info()as long
return 1
End Function

Function transfer_data(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn
    Dim As multireturn returnvalues
    dim as long returnvalue
    dim as long length = 0

	returnvalue =  libusb_interrupt_transfer(handle, endp, databuf, number, @length, timeout)
	
	If (suppress = 0) then
	?
	? "returnvalue "; returnvalue
	? *(libusb_error_name(returnvalue))
	End if
	
	returnvalues.A = length
	returnvalues.B = returnvalue
		
	return returnvalues
End Function



Function bulk_tranfer(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn

    Dim As multireturn returnvalues
    dim as long returnvalue
    dim as long length = 0

	returnvalue =  libusb_bulk_transfer(handle, endp, databuf, number, @length, timeout)
	
	If (suppress = 0) then
	'?
	'? "returnvalue "; returnvalue
	'? *(libusb_error_name(returnvalue))
	End if
	
	returnvalues.A = length
	returnvalues.B = returnvalue
		
	return returnvalues
End Function
