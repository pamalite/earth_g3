function SVG_supporting_check()
{


var hasSVGSupport = false; // whether the browser supports SVG


if (navigator.mimeTypes != null
&& navigator.mimeTypes.length > 0)
{
if (navigator.mimeTypes["image/svg+xml"] != null)
{

hasSVGSupport = true;
}
}



if (!hasSVGSupport)
{

alert('Sorry, your browser cannot support SVG\n the page unavailible');


}




}

