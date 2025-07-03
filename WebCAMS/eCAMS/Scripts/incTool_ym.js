//<!--$$Revision: 2 $-->
//<!--$$Author: Bo $-->
//<!--$$Date: 20/02/14 10:58 $-->
//<!--$$Logfile: /eCAMSSource2010/eCAMS/Scripts/incTool_ym.js $-->
//<!--$$NoKeywords: $-->
<!--
	var newWindow;
	function popupwindow(pHREF) {
		makeNewWindow(pHREF,'Details','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,width=700,height=700,alwaysRaised');
		return false;
	} //function popupwindow
	
	function makeNewWindow(strURL, strWindowName, strWindowFeatures){
		if (!newWindow || newWindow.closed) {
			newWindow = window.open(strURL, strWindowName,strWindowFeatures);
			if  (!newWindow.opener) {
				newWindow.opener = window;
			}
		} else {
			newWindow.location=strURL;
			newWindow.focus();
		}
        //force the windows to front if minimised
		newWindow.focus();

	} //function makeNewWindow

	//used by customised validator	
	function VerifyDate(source, args) {
		args.IsValid = validateDate(args.Value);
	} //
	
	//used by customised validator
	function VerifyTime(source, args) {
	//debugger;
		args.IsValid = validateTime(args.Value);
	} //function VerifyTime

	//used by customised validator
	//Make sure that the TradingHours is in correct format of hhmm-hhmm, 24 hour format, and begin hour is less than end hour
	//or value = close
	function VerifyTradingHours(source, args) {
		args.IsValid = (validateTradingHours(args.Value) || args.Value.toLowerCase() == 'close' || args.Value.toLowerCase() == 'closed');
	} //function VerifyTradingHours
	
	//validate date in format of dd/mm/yy
	function validateDate(entry){
	//rex=/\b(0?[1-9]|[12][0-9]|3[01])\/(1[0-2]|0?[1-9])\/\d\d\d\d/
	rex=/^(0?[1-9]|[12][0-9]|3[01])\/(1[0-2]|0?[1-9])\/\d\d$/
	return rex.test(entry)
	} //function validateDate

	//validate time in format of hh:mm:ss
	function validateTime(entry) {
	//debugger
	var a = new Array;
	//a = entry.match(/^(\d\d):(\d\d):(\d\d)$/);  //time in format of hh:mm:ss
	
	//time in format of hhmm
	if (isNaN(entry))
		return false;
	if (entry.length != 4)
		return false;
	
	//reformat to hh:mm:ss	
	entry = entry.slice(0,1) + entry.slice(1,2) + ':' + entry.slice(2,3) + entry.slice(3,4) + ':00' 
	a = entry.match(/^(\d\d):(\d\d):(\d\d)$/);  
	if ((a != null) &&
		(a[1] >= 0 && a[1] < 24) && 
		(a[2] >= 0 && a[2] < 60) &&
		(a[3] >= 0 && a[3] < 60))
		return true;
	return false;
	} //function validateTime

	//validate trading hours in 24 hour format hhmm-hhmm and end hour > begin hour
	function validateTradingHours(entry) {
	//debugger 0000-0000
	//check if the begin and end time are valid
	if ((entry.length == 9) && entry.slice(4,5) == "-" && (validateTime(entry.slice(0,4)) && validateTime(entry.slice(5,9)))) {
	    //check if end hour < begin hour
	    if (entry.slice(0,4) < entry.slice(5,9))
	        return true;
	  }
	  return false;
	} //function validateTradingHours


    function highlightRowViaCheckBox (checkbox, color) { 
        //this function will highlight table row via check box selection
        var tr; 
        //check if the it is the W3C DOM document hierarchy, if it is, loop nodes in hierarchy until <tr> found
        //In W3C DOM, we use parentNode and nodeName to loop through document hierarchy
        if (checkbox.parentNode) { 
            tr = checkbox.parentNode; 
            while (tr.nodeName.toLowerCase() != 'tr') 
            tr = tr.parentNode; 
        } 
        //check if it is DHTML object hierarchy, if it is, loop obejct hierarchy until <tr> found
        //In DHTML, we user parentElement and tagName to loop through object hierarchy
        else if (checkbox.parentElement) { 
            tr = checkbox.parentElement; 
            while (tr.tagName.toLowerCase() != 'tr') 
            tr = tr.parentElement; 
        } 
        //<tr> found, change the color
        if (tr) { 
            if (checkbox.checked) { 
            tr.oldBackgroundColor = tr.style.backgroundColor; 
            tr.style.backgroundColor = color; 
            } 
            else { 
            tr.style.backgroundColor = tr.oldBackgroundColor; 
            } 
        } 
   }  //function highlightRowViaCheckBox 
	function DoesControlExist(pDocument, pControlName) {
	//function to check if a control exists on a document
	    var elements = pDocument.getElementById(pControlName);

        if (elements==null)
            return false;
        else
            return true;
	}
	//left 
	function Left(str, n){ 
        if (n <= 0) 
            return ""; 
        else if (n > String(str).length) 
            return str; 
        else 
            return String(str).substring(0,n); 
    } 
    //right
    function Right(str, n){ 
        if (n <= 0) 
           return ""; 
        else if (n > String(str).length) 
           return str; 
        else { 
           var iLen = String(str).length; 
           return String(str).substring(iLen, iLen - n); 
        } 
    } 

    //get all the macthing controls
	function getDocumentAll(pDocument, pControlName) {
	    var inputs = pDocument.getElementsByTagName('input');
        var controls = [];
        for (var i = 0; i < inputs.length; i++) {
          //if (inputs[i].type == 'checkbox' && inputs[i].name == pControlName) {
          //debugger;
          if (Right(pControlName,1) == "*") {
              //wildcard matching
              if (Left(pControlName, 1) == "*") {
                  //*ControlID_*, wildcard at both sides
                  //debugger
                  if (String(inputs[i].name).indexOf(Right(Left(pControlName, pControlName.length-1), pControlName.length-2))>0) {
                    controls.push(inputs[i]);}
              }
              else
              {
                  //ControlID_*, wildcard at the end
                  if (Left(inputs[i].name, pControlName.length-1) == Left(pControlName, pControlName.length-1)) {
                    controls.push(inputs[i]);}
              }
          }
          else
          {
              if (inputs[i].name == pControlName) {
                controls.push(inputs[i]);}
          }
        }
        return controls;
    }
    
	function validateSofwareApplicationSelection(pDocument) {
		//debugger
		//validate bulk checkbox selection in pDocument
		var i, ret=false;
		var chk = getDocumentAll(pDocument, "*chkSoftwareApplication_*");  //Control generated with ClientID, such as <input id="ctl00_ContentPlaceHolder1_chkSoftwareApplication_25" type="checkbox"
		//alert (chk.length);
        //go through each check box
	    for (i=0; i<chk.length; i++) {
		    if (!chk[i].disabled && chk[i].checked) {
				ret = true;
				break;
		    }
	    }
	    //no check box found, set it to true
	    if (chk.length ==0) {
	        ret = true;}
	        
		return ret;
	}

	function validateBulkSelection(pDocument) {
		//debugger
		//validate bulk checkbox selection in pDocument
		var i, ret=false;
		var chk = getDocumentAll(pDocument, "chkBulk"); 
		//alert (chk.length);
        //go through each check box
	    for (i=0; i<chk.length; i++) {
		    if (!chk[i].disabled && chk[i].checked) {
				ret = true;
				break;
		    }
	    }
		return ret;
	}
	function selectAllchkBulk(pDocument) {
		//debugger;
		var i;
		var chk = getDocumentAll(pDocument, "chkBulk"); 
		//alert (chk.length);
        //go through each check box
	    for (i=0; i<chk.length; i++) {
		    if (!chk[i].disabled && !chk[i].checked) {
			    chk[i].checked = true;
			    //debugger
			    highlightRowViaCheckBox(chk[i], '#fff4c2');
		    }
	    }
		
		return false; //tell browser do not take default action
	}
	
//	function validateBulkSelection(pDocument) {
//		//debugger
//		//validate bulk checkbox selection in pDocument
//		var i, ret=false;
//		if (pDocument.all("chkBulk")) {
//			if (pDocument.all("chkBulk").length==undefined) {
//				//single row of check box
//				ret = pDocument.all("chkBulk").checked;
//			}
//			else
//			{
//				//multiple rows of check box
//				for (i=0; i<pDocument.all("chkBulk").length; i++) {
//					if (pDocument.all("chkBulk")[i].checked) {
//							ret = true;
//							break;
//					}
//				}
//			}
//		}
//		
//		return ret;
//	
//	}

//	function selectAllchkBulk(pDocument) {
//		//debugger
//		var i;
//		if (pDocument.all("chkBulk")) {
//			if (pDocument.all("chkBulk").length==undefined) {
//				//single row of check box
//				pDocument.all("chkBulk").checked = true;
//				highlightRowViaCheckBox(pDocument.all("chkBulk"), '#fff4c2');
//			}
//			else
//			{
//    	        //multiple rows of check box
//			    for (i=0; i<pDocument.all("chkBulk").length; i++) {
//				    if (!pDocument.all("chkBulk")[i].disabled && !pDocument.all("chkBulk")[i].checked) {
//					    pDocument.all("chkBulk")[i].checked = true;
//					    //debugger
//					    highlightRowViaCheckBox(pDocument.all("chkBulk")[i], '#fff4c2');
//				    }
//			    }
//			}
//		}
//		
//		return false; //tell browser do not take default action
//	}
	function isPositiveIntegerOrZero(arg) {
	    if (arg=="")
	        return false;
	        
	    if (isNaN(arg))
		    return false;
			
	    if (arg.indexOf("-") >= 0)
		    return false;
			
	    if (arg.indexOf(".") >= 0)
		    return false;
		    
		//finally
		return true;
	}
	function isPositiveInteger(arg) {
	    if (arg=="")
	        return false;

	    if (isNaN(arg))
		    return false;
			
	    if (arg.indexOf("-") >= 0)
		    return false;
			
	    if (arg.indexOf(".") >= 0)
		    return false;
		    
	    if (arg == 0)
		    return false;
		    		    
		//finally
		return true;
	}

	//used by customised validator	
	function VerifyPositiveIntegerOrZero(source, args) {
	//debugger;
		args.IsValid = isPositiveIntegerOrZero(args.Value); //args.Value has to be uppercase on the first letter
	} 
    //strip out HTML tag and return string
    function stripHTMLTag(html){
        var tmp = document.createElement("DIV");   
        tmp.innerHTML = html;   
        return tmp.textContent||tmp.innerText;
   }
   function ChangeCheckBoxBackColor(pElementID, pCheckedColor, pUncheckedColor) {
        //debugger;
        var chk = document.getElementById(pElementID);
        if (chk.checked == true) {
            chk.parentElement.style.backgroundColor = pCheckedColor;
        }
        else {
            chk.parentElement.style.backgroundColor = pUncheckedColor;
        }           
}

function ValidateCheckedAtLeastOne(chkBoxListClientID) {
    var chkBoxList = document.getElementById(chkBoxListClientID);
    var options = chkBoxList.getElementsByTagName('input');

    for (var i = 0; i < options.length; i++) {
        if (options[i].checked)
            return true;
    }

    return false;
}
	
//-->