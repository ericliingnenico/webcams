//<!--$$Revision: 1 $-->
//<!--$$Author: Bo $-->
//<!--$$Date: 22/01/13 8:28 $-->
//<!--$$Logfile: /eCAMSSource2010/eCAMS/Scripts/jqHelpTip_src.js $-->
//<!--$$NoKeywords: $-->
<!--
$(document).ready(function () {

    // we are going to run through each element begin with the helptip as class name (here use jquery wildcard matching)
    $('[class^="helptip"]').each(function () {
        //debugger;
        var _tipID = $(this).attr('helptipid');
        var _tipText = '';
        // the element has no rating tag or the rating tag is empty 
        if (_tipID == undefined || _tipID == '') {
            _tipText = '';
        }
        else {
            _tipText = $("#" + _tipID).html();
        }

        //helptipboxleft for multiple textboxes scenario, target to customised location
        var _tipLeftPos = $(this).attr('helptipboxleft');
        if (_tipLeftPos == undefined || _tipLeftPos == '') {
            _tipLeftPos = $(this).offset().left + $(this).width() + 10;
        }

        if (_tipText != '') {
            // create the tooltip for the current element 
            $(this).qtip({
                content: _tipText,
                position: {
                    my: 'middle left',  // Position my top left...
                    at: 'middle right', // at the bottom right of...
                    //target: $(this) // my target
                    target: [_tipLeftPos, $(this).offset().top]//$(this).top]
                },

                style: {
                    //classes: 'ui-tooltip-blue ui-tooltip-shadow'
                    classes: 'ui-tooltip ui-tooltip-rounded'
                },

                show: {
                    event: 'click',
                    solo: true,
                    effect: function (offset) {
                        $(this).slideDown(100); // "this" refers to the tooltip
                    }

                },
                hide: {
                    event: 'unfocus',
                    effect: function (offset) {
                        $(this).slideUp(100); // "this" refers to the tooltip
                    }

                }

            });
        }
    });
}); 
 
 function limitChars(textid, limit, infodiv) {
    //debugger;
	var text = $('#'+textid).val();	
	var textlength = text.length;
	if(textlength > limit)
	{
		$('#' + infodiv).html('limit to '+limit+' characters');
		$('#'+textid).val(text.substr(0,limit));
		return false;
	}
	else
	{
		$('#' + infodiv).html((limit - textlength) +' characters remain');
		return true;
	}
}

$(document).ready(function () {
    //debugger;

    $('.txtwithcounter').each(function () {
        //debugger;
        $(this).keyup(function () {
            limitChars($(this).attr("id"), $(this).attr('charlimit'), $(this).attr('charlimitinfo'));
        });
        $(this).trigger('keyup');
    });
});

//-->
