function Dsy() { this.Items = {}; }
Dsy.prototype.add = function(id,iArray) { this.Items[id] = iArray; } 
Dsy.prototype.Exists = function(id) { if(typeof(this.Items[id]) == "undefined") return false; return true; };
function change(v,aId){
	var str="0";
	var aTemp;
	if(aId==undefined){
			aId = s;
		}
	for(i=0;i<v;i++){  str+=("_"+(document.getElementById(aId[i]).selectedIndex-1))};
	var ss=document.getElementById(aId[v]);
	with(ss){
		length = 0;
		
		options[0]=new Option(opt0[v],opt0[v]);
		if(v && document.getElementById(aId[v-1]).selectedIndex>0 || !v)
		{
			if(dsy.Exists(str)){
				ar = dsy.Items[str];
				for(i=0;i<ar.length;i++)
				{
					aTemp = ar[i].split("|");
					options[length]=new Option(ar[i],ar[i]);
				}
				if(v)options[1].selected = true;
			}
		}
		if(++v<aId.length){change(v,aId);}
	}
}
var dsy = new Dsy();
dsy.add("0",["linux-3.8.13","Android-4.4.3","linux-3.5.4","linux-3.19.1"]);
dsy.add("0_0",["x86_32"]);
dsy.add("0_0_0",["real"]);
dsy.add("0_1",["arm-Nexus5"]);
dsy.add("0_1_0",["real"]);
dsy.add("0_1_0_0",["testcase3"]);
dsy.add("0_2",["x86_32"]);
dsy.add("0_2_0",["virtual","real"]);
dsy.add("0_2_0_0",["testcase1","testcase2"]);
dsy.add("0_3_0",["real"]);
dsy.add("0_3",["x86_64"])
