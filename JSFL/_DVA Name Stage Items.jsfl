if (fl.getDocumentDOM().selection.length > 0)
{
	for(i in fl.getDocumentDOM().selection)
	{
        if(fl.getDocumentDOM().selection[i].instanceType == "symbol")
        {
            path = fl.getDocumentDOM().selection[i].libraryItem.name;
            mc_name = path.substr(path.lastIndexOf("/")+1);
            fl.getDocumentDOM().selection[i].name = mc_name + "_mc";
        }
	}
}
