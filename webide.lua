return function (port)
    
    srv=net.createServer(net.TCP) 
    srv:listen(port,function(c) 

       local rnrn=0
       local Status = 0
       local DataToGet = 0
       local method=""
       local url=""
       local vars=""
       local buff=""
       local requestFilelist=0
       local filecount=0

      c:on("receive",function(c,payload) 
        
        if Status==0 then
            _, _, method, url, vars = string.find(payload, "([A-Z]+) /([^?]*)%??(.*) HTTP")
            --print("method:" .. method, "url:" .. url, "vars:" .. vars)                     
        end
        
        if method=="POST" then
            local i=0
            local j=0
            i,j = string.find(url, '.lua')
            url = string.sub(url, 1, j)
            i = nil
            j = nil
            if Status==0 then
                _,_,DataToGet, payload = string.find(payload, "Content%-Length: (%d+)(.+)")
                
                if DataToGet~=nil then
                    DataToGet = tonumber(DataToGet)
                    print(DataToGet)
                    rnrn=1
                    Status = 1
                else
                    print("bad length")
                end
            end
            
            -- find /r/n/r/n
            if Status==1 then
                local payloadlen = string.len(payload)
                local mark = "\r\n\r\n"
                local i
                for i=1, payloadlen do                
                    if string.byte(mark, rnrn) == string.byte(payload, i) then
                        rnrn=rnrn+1
                        if rnrn==5 then 
                            payload = string.sub(payload, i+1,payloadlen)
                            file.open(url, "w")
                            file.close() 
                            Status=2
                            break
                        end
                    else
                        rnrn=1
                    end
                end    
                if Status==1 then 
                    return 
                end
            end
        
            if Status==2 then
                if payload~=nil then
                    DataToGet=DataToGet-string.len(payload)
                    --print("DataToGet:", DataToGet, "payload len:", string.len(payload))
                    file.open(url, "a+")
                    file.write(payload)
                    file.close() 
                else
                    c:send("HTTP/1.1 200 OK\r\n\r\nERROR")
                    Status=0
                end

                if DataToGet==0 then                
                    c:send("HTTP/1.1 200 OK\r\n\r\nOK")
                    Status=0
                end            
            end
            
            return
        
        elseif method == "GET" then
        
            DataToGet = -1
            
            if url == "favicon.ico" then
                c:send("HTTP/1.1 404 file not found")
                return
            end    

            buff=buff.."HTTP/1.1 200 OK\r\n\r\n"
            buff = buff.."<!DOCTYPE html>\n"
            -- it wants a file in particular
            if url~="" and vars=="" then
                DataToGet = 0
                if file.open(url, "r") then 
                    local line = file.readline()
                    DataToGet = string.len(line)
                    c:send(line)
                    file.close()
                end
                return
            end    

            buff=buff.."<html><body><h1>NodeMCU ESP"..node.chipid().."</h1>"
            
            if vars=="edit" then
                buff=buff.."<script>function tag(c){document.getElementsByTagName('w')[0].innerHTML=c};\n"
                buff=buff.."var x=new XMLHttpRequest()\n"
                buff=buff.."x.onreadystatechange=function(){if(x.readyState==4) document.getElementsByName('t')[0].value = x.responseText; };\n"
                buff=buff.."x.open('GET',location.pathname,true)\nx.send()</script>"
                buff=buff.."<a href='/'>Back to file list</a><br><br><textarea name=t cols=90 rows=25></textarea></br><br><w></w><br><br>"
                buff=buff.."<button onclick=\"tag('Saving');x.open('POST',location.pathname,true);\nx.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};\nx.send(new Blob([document.getElementsByName('t')[0].value],{type:'text/plain'}));\">Save</button>\n&nbsp;&nbsp;&nbsp;&nbsp;"
                buff=buff.."<button onclick=\"tag('Running');x.open('GET',location.pathname+'?run',true);\nx.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};\nx.send();\">Run</button>\n&nbsp;&nbsp;&nbsp;&nbsp;"
                buff=buff.."<button onclick=\"tag('Running');x.open('GET',location.pathname+'?remove',true);\nx.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};\nx.send();\">Remove</button>"
            end    

            if vars=="run" then
                buff=""
                dofile(url)
                c:send("HTTP/1.1 200 OK\r\n\r\nExecuted")
                return
            --[[
                buff=buff.."<verbatim>"
                local st, result=pcall(dofile, url)
                buff=buff..tostring(result)
                print('running ===== '..tostring(result))
                buff=buff.."</verbatim>"
            ]]--
            end
            
            if vars=="remove" then
                if file.open(url, 'r') then
                    file.close()
                    file.remove(url)
                    c:send("HTTP/1.1 200 OK\r\n\r\nRemoved")
                else
                    c:send("HTTP/1.1 200 OK\r\n\r\nNot Found")
                end
                return
            end
            
            if url=="" then
                requestFilelist=1
                buff=buff.."<script>function tag(c){document.getElementsByTagName('w')[0].innerHTML=c};\n"
                buff=buff.."var x=new XMLHttpRequest()\n</script>\n<w></w>"
                buff=buff.."<table border=\"1\" cellspacing=\"0\" cellpadding=\"5\">\n<tr><td>File Name</td><td>Size</td><td>Edit</td><td>Run</td><td>Remove</td></tr>\n"
                local l = file.list();
                print('file list count:'..table.getn(l))
                for k,v in pairs(l) do  
                    --print('send',k,v)
                    filecount=filecount+1
                    --buff=buff.."<a href='"..k.."?edit'>"..k.."</a>, size:"..v.."<br>"
                    buff=buff.."<tr><td>"..k.."</td><td>"..v.."k</td><td><input type=\"button\" value=\"Edit\"  onclick=\"window.location.href='"..k.."?edit'\" /></td>"
                    buff=buff.."<td><input type='button' value='Run' onclick=\"tag('Running');x.open('GET','/"..k.."?run',true);\nx.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};\nx.send();\" /></td>"
                    buff=buff.."<td><input type='button' value='Remove' onclick=\"tag('Running');x.open('GET','/"..k.."?remove',true);\nx.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};\nx.send();\" /></td></tr>"
                    c:send(buff)
                    buff=""
                return
                end
            end
            
            buff=buff.."</body></html>"
            
            c:send(buff)
            buff=""
            collectgarbage()
            c:close()
        end 
            
      end)
      c:on("sent",function(c)
        if DataToGet>=0 and method=="GET" then
            if file.open(url, "r") then
                file.seek("set", DataToGet)
                local line=file.read(512)
                file.close()
                if line then
                    c:send(line)
                    DataToGet = DataToGet + 512
                
                    if (string.len(line)==512) then
                        return
                    end
                end
            end
        end
        
        if requestFilelist==1 and filecount>=1 then
            buff=""
            local l = file.list();
            local count=0
            for k,v in pairs(l) do
                count=count+1
                if count==filecount+1 then
                    --print('sent',k,v)
                    filecount=filecount+1
                    buff=buff.."<tr><td>"..k.."</td><td>"..v.."k</td><td><input type=\"button\" value=\"Edit\"  onclick=\"window.location.href='"..k.."?edit'\" /></td>"
                    buff=buff.."<td><input type='button' value='Run' onclick=\"tag('Running');x.open('GET','/"..k.."?run',true);\nx.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};\nx.send();\" /></td>"
                    buff=buff.."<td><input type='button' value='Remove' onclick=\"tag('Running');x.open('GET','/"..k.."?remove',true);\nx.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};\nx.send();\" /></td></tr>"
                    c:send(buff)
                    return
                end
            end
            buff=buff.."</table>\n</body></html>"
            requestFilelist=0
            filecount=0
            c:send(buff)
            return
        end
        buff=""
        
        print(' ===== c on sent =====')
        collectgarbage()
        c:close() 
      end)
    end)
    print("listening on port " .. port .. ", free:" .. node.heap())
    collectgarbage()
    return srv
end