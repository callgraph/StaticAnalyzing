<script >
function showmenu(id)
{
    var g_id=document.getElementById(id);
    var d_id = document.getElementById(id+"t");
    if(g_id.getAttribute("visibility")=="hidden")
    {
    	g_id.setAttribute("visibility","visible");
    	d_id.style.fill="#00ff00";
    	d_id.style.fontSize="40px";
    }
    else
    {
    	g_id.setAttribute("visibility","hidden");
    	d_id.style.fill="#0000ff";
    	d_id.style.fontSize="30px";
    }
}
</script>
