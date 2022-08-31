--[[
README:

goto my repository https://github.com/zhang-changwei/Automation-scripts-for-Aegisub for the latest version

]]

script_name="C Utilities Chinese"
script_description="Utilities Chinese v1.6"
script_author="chaaaaang"
script_version="1.6" 

include('karaskel.lua')
re = require 'aegisub.re'
clipboard = require 'aegisub.clipboard'
Yutils = nil

local visualization_max_width, visualization_max_height = 180, 41

local dialog_config = {
	{class="label",label="选项",x=0,y=0},--1
	{class="dropdown",name="option",
		items={"AE序列图导入","矢量图控制点居中","删除空白行","删除SDH注释",
		"对白检查器","摩卡数据可视化","移动!","多行文字导入","用\\N分隔双语字幕","多行文字Shift","双语字幕前后对调"},
		x=1,y=0,width=5},--2
    -- 删除SDH注释
    {class="label",label="■ 删除SDH注释",x=0,y=1,width=2},--3
    {class="checkbox",name="SDH_m",label="[...]",value=true,x=0,y=2},--4
    {class="checkbox",name="SDH_s",label="(...)",value=true,x=1,y=2},--5
    {class="checkbox",name="SDH_l",label="{...}",value=false,x=0,y=3},--6
    {class="checkbox",name="SDH_h",label="<...>",value=false,x=1,y=3},--7
    {class="checkbox",name="SDH_M",label="【...】",value=false,x=0,y=4},--8
    {class="checkbox",name="SDH_S",label="（...）",value=false,x=1,y=4},--9
	{class="dropdown",name="SDH_speaker",items={"XXX:","off","CAPITALIZED WORD","CAPITALIZED WORD + numbers","CAPITALIZED WORDS","CAPITALIZED WORDS + numbers","one word","one word(include numbers)","one word(nonEnglish language)","words","words(include numbers)","words(nonEnglish language)"},value="XXX:",x=0,y=5,width=3,hint="在下列选项中选中一种说话人样式"},
    {class="checkbox",name="SDH_o",label="其他匹配规则",value=false,x=0,y=6},--11
    {class="edit",name="SDH_other",x=0,y=7,width=2,hint="规则间用半角空格分隔"},--12
    {class="label",label="to",x=0,y=8},--13
    {class="edit",name="SDH_to",value=" ",x=0,y=9,width=2,hint="默认: 一个空格"},--14
	-- 移动!
	{class="label",label="■ 移动!",x=3,y=1,width=2},--15
	{class="checkbox",name="move_pos",label="pos",value=true,x=3,y=2},--16
	{class="checkbox",name="move_clip",label="clip",value=false,x=4,y=2},--17
	{class="checkbox",name="move_org",label="org",value=false,x=5,y=2},--18
	{class="checkbox",name="move_move",label="move",value=false,x=3,y=3},--19
	{class="checkbox",name="move_move2",label="moves3/moves4",value=false,x=4,y=3,width=2},--20
	{class="label",label="x",x=3,y=4},--21
	{class="floatedit",name="move_x",value=0,x=4,y=4,width=2},--22
	{class="label",label="y",x=3,y=5},--23
	{class="floatedit",name="move_y",value=0,x=4,y=5,width=2},--24
	-- 对白检查器
	{class="label",label="■ 对白检查器",x=3,y=6,width=2},--25
	{class="checkbox",label="时间轴重叠检查",name="dialog_olp",value=true,x=3,y=7,width=2},--26
	{class="checkbox",label="双语检查",name="dialog_bl",value=true,x=3,y=8,width=2},--27
	{class="dropdown",name="dialog_blstyle",items={"zho\\Neng","zho\\Nany","any\\Neng","any\\Nany"},value="zho\\Neng",x=3,y=9,width=3},--28
	{class="checkbox",label="长句检查",name="dialog_ol",value=true,x=3,y=10,width=3},--29
	{class="label",label="buffer 1",x=3,y=11},--30
	{class="floatedit",name="dialog_bf1",value=0.6,x=4,y=11,width=2,hint="Buffer for 中文字幕, 参数范围:0-1. 长句检查二级参数, 越小的buffer表示字幕有越小的空间"},
    {class="label",label="buffer 2",x=3,y=12},--32
	{class="floatedit",name="dialog_bf2",value=0.75,x=4,y=12,width=2,hint="Buffer for 英文字幕, 参数范围:0-1. 长句检查二级参数, 越小的buffer表示字幕有越小的空间"},
	-- AE序列图导入
	{class="label",label="■ AE序列图导入",x=7,y=1,width=2},--34
	{class="label",label="FPS",x=7,y=2},--35
	{class="floatedit",name="ae_fps",value=23.976,x=8,y=2},--36
	{class="label",label="淡入时间",x=7,y=3},--37
	{class="intedit",name="ae_fin",value=0,x=8,y=3},--38
	{class="label",label="淡出时间",x=7,y=4},--39
	{class="intedit",name="ae_fout",value=0,x=8,y=4},--40
	{class="label",label="图片宽度",x=7,y=5},--41
	{class="intedit",name="ae_w",value=1920,x=8,y=5},--42
	{class="label",label="图片高度",x=7,y=6},--43
	{class="intedit",name="ae_h",value=1080,x=8,y=6},--44
	-- 多行文字导入
	{class="label",label="■ 多行文字导入",x=7,y=7,width=2},--45
	{class="checkbox",label="从文件",name="mi_file",x=7,y=8},--46
	{class="checkbox",label="从剪切板",value=true,name="mi_clip",x=8,y=8},--47
	-- Tag Copy
	-- {class="label",label="■ Tag Copy",x=7,y=5,width=2},--40
	-- {class="checkbox",name="copy_head",label="head",value=true,x=7,y=6},--41
	-- {class="checkbox",name="copy_N",label="\\N     ",value=true,x=8,y=6},--42
	-- {class="checkbox",name="copy_I",label="|",value=false,x=9,y=6},--43
	-- {class="label",label="Copy your template line here",x=7,y=7,width=3},--44
	-- {class="edit",name="copy_template",value="",x=7,y=8,width=3},--45
	-- 摩卡数据可视化
	{class="label",label="■ 摩卡数据可视化",x=7,y=9,width=2},--48
	{class="label",label="模式",x=7,y=10},--49
	{class="dropdown",name="data_mode",items={"x-t","t-x"},value="x-t",x=8,y=10},--50
	{class="label",label="对象",x=7,y=11},--51
	{class="dropdown",name="data_obj",items={"x","y","fscx","fscy","frz"},x=8,y=11},--52
	{class="checkbox",name="data_num",label="显示行序号",value=true,x=8,y=12},--53
	-- 多行文字Shift
	{class="label",label="■ 多行文字Shift",x=0,y=10,width=2},--54
	{class="checkbox",label="向后",name="shift_b",value=false,x=0,y=11},--55
	{class="checkbox",label="向前",name="shift_f",value=false,x=1,y=11,width=2},--56
	{class="floatedit",name="shift_n",value=1,x=0,y=12},--57
	{class="label",label="行",x=1,y=12},--58
	-- forget stuff
	
    -- note
	{class="label",label="         ",x=2,y=1},
	{class="label",label="         ",x=6,y=1},
	
	{class="label",label="AE序列图导入: ",x=0,y=14},
	{class="label",label="按下AE按钮抓取AE序列图路径并运行",x=1,y=14,width=7},
	{class="label",label="在文件拾取器中选择序号为001的图片",x=1,y=15,width=6},
	{class="label",label="矢量图控制点居中:",x=0,y=16},
	{class="label",label="需要Yutils库，仅在行内存在\\an7标签时生效.",x=1,y=16,width=5},
	{class="label",label="删除空白行:",x=0,y=17},
	{class="label",label="这个程序可能无法正常终止，无视它即可",x=1,y=17,width=7},
	{class="label",label="对白检查器:",x=0,y=18},
	{class="label",label="长句检查要求Yutils库",x=1,y=18,width=7},
	{class="label",label="移动!:",x=0,y=19},
	{class="label",label="矢量遮罩移动需要Yutils库",x=1,y=19,width=7}
}
local buttons = {"Run","AE","Quit"}

--This is the main processing function that modifies the subtitles
function main(subtitle, selected, active)
    local meta,styles=karaskel.collect_head(subtitle,false)
	local xres, yres, ar, artype = aegisub.video_size()
	local ae_path = nil
	-- local copy_template,copy_template_2 = {},{}
	local data = {} -- 多行文字导入 & Mocha Visualization
	local data_max,data_min,data_index = 0,0,1

	-- change the content shown in UI
	-- Tag Copy
	-- dialog_config[45].value = clipboard.get()
	-- AE
	dialog_config[42].value = xres
	dialog_config[44].value = yres

    local pressed, result = aegisub.dialog.display(dialog_config,buttons)
    if (pressed=="Quit") then aegisub.cancel() end
	if (pressed=="AE") then
		ae_path = aegisub.dialog.open('AE Choose the file with INDEX 001', '', '', 'PNG files (.png)|*.png|All Files (.)|.', false, true)
	end
	if pressed=="Run" and result.option=="AE序列图导入" then
		aegisub.log("Please the AE button")
		aegisub.cancel()
	end
	if (pressed=="AE" and result.option~="AE序列图导入") or (pressed=="AE" and ae_path==nil) then
		aegisub.cancel()
	end

	-- Yutils
	if result.option=="对白检查器" and result.dialog_ol==true then 
		Yutils = require('Yutils')
	elseif result.option=="矢量图控制点居中" then 
		Yutils = require('Yutils')
	elseif result.option=="移动!" and result.move_clip==true then
		Yutils = require('Yutils')
	end

	-- log
	local log = {}
	log.overlength,log.overlap,log.bilang = 0,0,0
	-- count
	local N = #selected

	-- Stuff shaould be done before the loop
	if result.option=="删除空白行" then
		local i = 1
		local total = #subtitle
		while(i<=total) do
			local li = subtitle[i]
			if li.class=="dialogue" then
				li.text = li.text:gsub("{}","")
				li.text = li.text:gsub(" *","")
				if li.text=="" then
					subtitle.delete(i)
					total = total - 1
				else
					i = i + 1
				end
			else
				i = i + 1
			end
		end
		goto loop_end
	elseif result.option=="多行文字导入" then
		if result.mi_clip==true and result.mi_file==false then
			local file = clipboard.get()
			file = file.."\n"
			for j in file:gmatch("(.-)\n") do
				j = j:gsub("^[ \t]+","")
				j = j:gsub("[ \t]+$","")
				if j~="" then
					table.insert(data,j)
				end
			end
		elseif result.mi_clip==false and result.mi_file==true then
			local file_path = aegisub.dialog.open('多行文字导入', '', '', 'TEXT files (.txt)|*.txt|All Files (.)|.', false, true)
			local file = io.open(file_path,"r")
			for j in file:lines() do
				j = j:gsub("^[ \t]+","")
				j = j:gsub("[ \t]+$","")
				if j~="" then
					table.insert(data,j)
				end
			end
			file:close()
		else
			aegisub.cancel()
		end
	end

    for si,li in ipairs(selected) do
        local line=subtitle[li]
        karaskel.preproc_line(subtitle,meta,styles,line)

        local linetext = line.text:match("^{")~=nil and line.text or "{}"..line.text
        linetext = linetext:gsub("}{","")

		if result.option=="AE序列图导入" then
			local ae_mid,ae_post = ae_path:match("(%d+)([^%d%.]*%.[^%.]+)$")
			local ae_pre = ae_path:gsub("(%d+)([^%d%.]*%.[^%.]+)$","",1)
			local ae_timeU = 1000/result.ae_fps
			local ae_timeS,ae_timeE = line.start_time,line.end_time
			local ae_fin,ae_fout = result.ae_fin,result.ae_fout
			local j,ki,ko = 1,1,1

			while ae_timeS+(j-0.5)*ae_timeU<ae_timeE do
				subtitle.insert(li+j-1,line)
				local new_line = subtitle[li+j-1]
				new_line.start_time = ae_timeS + math.floor((j-1) * ae_timeU)
				new_line.end_time = ae_timeS + math.floor(j * ae_timeU)

				if j<10 then ae_mid = ae_mid:gsub("%d$",j)
				elseif j<100 then ae_mid = ae_mid:gsub("%d%d$",j)
				elseif j<1000 then ae_mid = ae_mid:gsub("%d%d%d$",j)
				elseif j<10000 then ae_mid = ae_mid:gsub("%d%d%d%d$",j)
				else ae_mid = ae_mid:gsub("%d%d%d%d%d$",j)
				end
				new_line.text = "{\\an7\\pos(0,0)\\bord0\\shad0\\fscx100\\fscy100\\1img("..ae_pre..ae_mid..ae_post..")\\p1}"
				new_line.text = new_line.text..string.format("m 0 0 l %d 0 l %d %d l 0 %d",result.ae_w,result.ae_w,result.ae_h,result.ae_h)

				subtitle[li+j-1] = new_line
				j = j + 1
			end

			if ae_fin>0 then
				while ae_fin>0 and ki<=j-1 do
					-- first line: li
					local new_line = subtitle[li+ki-1]
					local ft = ((ki-0.5)*ae_timeU)/result.ae_fin
					local ae_ft = ae_timeU/2/ft

					new_line.text = new_line.text:gsub("^{",string.format("{\\fad(%d,0)",ae_ft))
					subtitle[li+ki-1] = new_line
					ae_fin = ae_fin - math.ceil(ae_timeU)
					ki = ki + 1
				end
			end
			if ae_fout>0 then
				while ae_fout>0 and ko<=j-1 do
					-- last line: li+j-2
					local new_line = subtitle[li+j-2-(ko-1)]
					local ft = ((ko-0.5)*ae_timeU)/result.ae_fout
					local ae_ft = ae_timeU/2/ft

					if new_line.text:match("\\fad")==nil then
						new_line.text = new_line.text:gsub("^{",string.format("{\\fad(0,%d)",ae_ft))
					else
						new_line.text = new_line.text:gsub("^{\\fad%((%d+),0%)","{\\fad(%1,"..string.format("%d)",ae_ft))
					end
					subtitle[li+j-2-(ko-1)] = new_line
					ae_fout = ae_fout - math.ceil(ae_timeU)
					ko = ko + 1
				end
			end

			line.comment = true
			linetext = linetext:gsub("^{}","")
			subtitle[li+j-1] = line
			goto loop_end

        elseif result.option=="矢量图控制点居中" then
            -- local Yutils = require('Yutils')

            local posx,posy = drawing_position(linetext,line,xres,yres)
            if linetext:match("\\pos")==nil then linetext=linetext:gsub("^{","{\\pos("..posx..","..posy..")") end
            if linetext:match("\\an%d")==nil then linetext=linetext:gsub("^{","{\\an"..line.styleref.align) end
            if linetext:match("\\fsc[%d%.]")~=nil then linetext=linetext:gsub("\\fsc([%d%.%-]+)","\\fscx%1\\fscy%1") end
            if linetext:match("\\fscy")==nil then linetext=linetext:gsub("^{","{\\fscy"..line.styleref.scale_y) end
            if linetext:match("\\fscx")==nil then linetext=linetext:gsub("^{","{\\fscx"..line.styleref.scale_x) end

            if linetext:match("\\an(%d)")~="7" then 
                aegisub.log("Please add \'\\an7\' tag first")
                aegisub.cancel()
            end

            local pnum = linetext:match("\\p(%d)")
            local scale_x = linetext:match("\\fscx([%d%.]+)")/100
            local scale_y = linetext:match("\\fscy([%d%.]+)")/100

            local shape = linetext:match("^{[^}]*}([^{]*)")
            local flatten_shape = Yutils.shape.flatten(shape)
            local xmin,ymin = flatten_shape:match("([%d%.%-]+) +([%d%.%-]+)")
            local xmax,ymax = xmin,ymin

            for x,y in flatten_shape:gmatch("([%d%.%-]+) +([%d%.%-]+)") do
                xmin = math.min(x,xmin)
                xmax = math.max(x,xmax)
                ymin = math.min(y,ymin)
                ymax = math.max(y,ymax)
            end
            local cx,cy = (xmin+xmax)/2, (ymin+ymax)/2
            local px,py = posx+cx*scale_x/(2^(pnum-1)) , posy+cy*scale_y/(2^(pnum-1))
            linetext = linetext:gsub("\\pos[^%)]+%)","\\pos("..px..","..py..")")

            shape = Yutils.shape.filter(shape, function (x,y) return x-cx,y-cy end)

            linetext = linetext:gsub("^({[^}]*})[^{]*",function (a) return a..shape end)
        elseif result.option=="删除SDH注释" then
            linetext = linetext:gsub("^{}","")
            if result.SDH_m==true then linetext = linetext:gsub("%[[^]]*]",result.SDH_to) end
            if result.SDH_s==true then linetext = linetext:gsub("%([^%)]*%)",result.SDH_to) end
            if result.SDH_l==true then linetext = linetext:gsub("{[^}]*}",result.SDH_to) end
            if result.SDH_h==true then linetext = linetext:gsub("<[^>]*>",result.SDH_to) end
            if result.SDH_M==true then linetext = re.sub(linetext, "【[^】]*】", result.SDH_to) end
            if result.SDH_S==true then linetext = re.sub(linetext, "（[^）]*）", result.SDH_to) end
            if result.SDH_o==true then
                for i in result.SDH_other:gmatch("([^,]+)") do
                    linetext = re.sub(linetext,i,result.SDH_to)
                end
            end
			if result.SDH_speaker~="off" and result.SDH_speaker~="XXX:" then
				if result.SDH_speaker=="CAPITALIZED WORD" then
					linetext = linetext:gsub("%u+ *: *",result.SDH_to)
				elseif result.SDH_speaker=="CAPITALIZED WORD + numbers" then
					linetext = linetext:gsub("[%u%d]+ *: *",result.SDH_to)
				elseif result.SDH_speaker=="CAPITALIZED WORDS" then
					linetext = linetext:gsub("(%p)[%u ]-: *","%1"..result.SDH_to)
					linetext = linetext:gsub("^[%u ]-: *",result.SDH_to)
				elseif result.SDH_speaker=="CAPITALIZED WORDS + numbers" then
					linetext = linetext:gsub("(%p)[%u%d ]-: *","%1"..result.SDH_to)
					linetext = linetext:gsub("^[%u%d ]-: *",result.SDH_to)

				elseif result.SDH_speaker=="one word" then
					linetext = linetext:gsub("%a+ *: *",result.SDH_to)
				elseif result.SDH_speaker=="one word(include numbers)" then
					linetext = linetext:gsub("[%a%d]+ *: *",result.SDH_to)
				elseif result.SDH_speaker=="one word(nonEnglish language)" then
					linetext = linetext:gsub("[^%p ]+ *: *",result.SDH_to)

				elseif result.SDH_speaker=="words" then
					linetext = linetext:gsub("(%p)[%a ]-: *","%1"..result.SDH_to)
					linetext = linetext:gsub("^[%a ]-: *",result.SDH_to)
				elseif result.SDH_speaker=="words(include numbers)" then
					linetext = linetext:gsub("(%p)[%a%d ]-: *","%1"..result.SDH_to)
					linetext = linetext:gsub("^[%a%d ]-: *",result.SDH_to)
				elseif result.SDH_speaker=="words(nonEnglish language)" then
					linetext = linetext:gsub("(%p)[%P]-: *","%1"..result.SDH_to)
					linetext = linetext:gsub("^[%P]-: *",result.SDH_to)		
				end
			end
		elseif result.option=="对白检查器" then
			linetext = linetext:gsub("^{}","")
			if result.dialog_ol==true then
				local _,count = linetext:gsub("\\N","")
				if count==0 then
					local w1 = line.width
					if linetext:match("\\fsc[%d%.]")~=nil then w1=w1*linetext:match("\\fsc([%d%.]+)")/line.styleref.scale_x end
					if linetext:match("\\fscx[%d%.]")~=nil then w1=w1*linetext:match("\\fscx([%d%.]+)")/line.styleref.scale_x end
					if linetext:match("\\fs[%d%.]")~=nil then w1=w1*linetext:match("\\fs([%d%.]+)")/line.styleref.fontsize end
					if w1>=xres*result.dialog_bf1 then 
						line.actor = line.actor.."overlength "
						log.overlength = log.overlength + 1
					end
				elseif count==1 then
					-- local Yutils = require('Yutils')
					local chs,eng = linetext:match("(.*)\\N(.*)")
					local chss,engs = chs:gsub("{([^}]*)}",""),eng:gsub("{([^}]*)}","")
					
					local name,scale_x,size,hspace = line.styleref.fontname,line.styleref.scale_x,line.styleref.fontsize,line.styleref.spacing
					if chs:match("\\fn")~=nil then name=chs:match("\\fn([^\\}]+)") end
					if chs:match("\\fsc[%d%.]")~=nil then scale_x=chs:match("\\fsc([%d%.]+)") end
					if chs:match("\\fscx[%d%.]")~=nil then scale_x=chs:match("\\fscx([%d%.]+)") end
					if chs:match("\\fs[%d%.]")~=nil then size=chs:match("\\fs([%d%.]+)") end
					if chs:match("\\fsp[%d%.%-]")~=nil then hspace=chs:match("\\fs([%d%.%-]+)") end

					local name2,scale_x2,size2,hspace2 = name,scale_x,size,hspace
					if eng:match("\\r")~=nil then 
						for j=1,1000 do
							local style = subtitle[j]
							if style.class=="style" and style.name==eng:match("\\r([^\\}]+)") then
								name2 = style.fontname
								scale_x2 = style.scale_x
								size2 = style.fontsize
								hspace2 = style.spacing
								break
							end
						end
					end
					if eng:match("\\fn")~=nil then name2=eng:match("\\fn([^\\}]+)") end
					if eng:match("\\fsc[%d%.]")~=nil then scale_x2=eng:match("\\fsc([%d%.]+)") end
					if eng:match("\\fscx[%d%.]")~=nil then scale_x2=eng:match("\\fscx([%d%.]+)") end
					if eng:match("\\fs[%d%.]")~=nil then size2=eng:match("\\fs([%d%.]+)") end
					if eng:match("\\fsp[%d%.%-]")~=nil then hspace2=eng:match("\\fs([%d%.%-]+)") end
					
					local CHS_HANDLE = Yutils.decode.create_font(name,false,false,false,false,size,scale_x/100,1,hspace)
					local ENG_HANDLE = Yutils.decode.create_font(name2,false,false,false,false,size2,scale_x2/100,1,hspace2)
					local w1,w2 = CHS_HANDLE.text_extents(chss).width,ENG_HANDLE.text_extents(engs).width

					if w1>=xres*result.dialog_bf1 or w2>=xres*result.dialog_bf2 then
						line.actor = line.actor.."overlength "
						log.overlength = log.overlength + 1
					end
				end
			end
			
			if result.dialog_olp==true and si~=N and line.end_time>subtitle[li+1].start_time then
				line.actor = line.actor.."overlap "
				local nextline = subtitle[li+1]
				nextline.actor = nextline.actor.."overlap "
				subtitle[li+1] = nextline
				log.overlap = log.overlap + 1
			end
			if result.dialog_bl==true then
				local _,count = linetext:gsub("\\N","")
				if count==1 then
					local chs,eng = linetext:match("(.*)\\N(.*)")
					chs,eng = chs:gsub("{[^}]*}",""),eng:gsub("{[^}]*}","")
					chs,eng = chs:gsub(" +",""),eng:gsub(" +","")
					if result.dialog_blstyle=="zho\\Neng" then
						if chs:match("[\128-\191]")~=nil and eng:match("[\128-\191]")==nil then
						else
							line.actor = line.actor.."bilang "
							log.bilang = log.bilang + 1
						end
					elseif result.dialog_blstyle=="zho\\Nany" then
						if chs:match("[\128-\191]")~=nil and eng~="" then
						else
							line.actor = line.actor.."bilang "
							log.bilang = log.bilang + 1
						end
					elseif result.dialog_blstyle=="any\\Neng" then
						if chs~="" and eng:match("[\128-\191]")==nil then
						else
							line.actor = line.actor.."bilang "
							log.bilang = log.bilang + 1
						end
					elseif result.dialog_blstyle=="any\\Nany" then
						if chs~="" and eng~="" then
						else
							line.actor = line.actor.."bilang "
							log.bilang = log.bilang + 1
						end
					end
				else
					line.actor = line.actor.."bilang "
					log.bilang = log.bilang + 1
				end
			end
		elseif result.option=="Empty Mocha Data" then
			-- local start_f,end_f = aegisub.frame_from_ms(line.start_time),aegisub.frame_from_ms(line.end_time)
			-- local data = ""
			-- data = data.."Adobe After Effects 6.0 Keyframe Data\n"
			-- data = data.."\n"
			-- data = data.." Units Per Second	23.976\n"
			-- data = data.." Source Width	1920\n"
			-- data = data.." Source Height	1080\n"
			-- data = data.." Source Pixel Aspect Ratio	1\n"
			-- data = data.." Comp Pixel Aspect Ratio	1\n"
			-- data = data.."\n"
			-- data = data.."Position\n"
			-- data = data.." Frame	X pixels	Y pixels	Z pixels\n"
			-- for i=0,end_f-start_f-1 do
			-- 	data = data.." "..i.." 0 0 0\n"
			-- end
			-- data = data.."\n"
			-- data = data.."Scale\n"
			-- data = data.." Frame	X percent	Y percent	Z percent\n"
			-- for i=0,end_f-start_f-1 do
			-- 	data = data.." "..i.." 100 100 100\n"
			-- end
			-- data = data.."\n"
			-- data = data.."Rotation\n"
			-- data = data.." Frame	Degrees\n"
			-- for i=0,end_f-start_f-1 do
			-- 	data = data.." "..i.." 0\n"
			-- end
			-- data = data.."\n"
			-- data = data.."End of Keyframe Data\n"
			-- aegisub.log(data.."\nThe Mocha Data have been copied to the clipboard!")
			-- clipboard.set(data)
			-- aegisub.cancel()
		elseif result.option=="摩卡数据可视化" then
			linetext = linetext:gsub("^{}","")
			if (N>visualization_max_height and result.data_mode=="x-t") or (N>visualization_max_width and result.data_mode=="t-x") then 
				aegisub.log("too many lines")
				aegisub.cancel()
			end
			if si==1 and result.data_num==true then
				for j=1,1000 do
					if subtitle[j].class=="dialogue" then
						data_index = li - j + 1
						break
					end
				end
			end
			-- get information
			local temp = nil
			if result.data_obj=="x" then
				temp = tonumber(linetext:match("\\pos%(([%d%.%-]+)"))
				table.insert(data,temp)
			elseif result.data_obj=="y" then
				temp = tonumber(linetext:match("\\pos%([^,]*,([%d%.%-]+)"))
				table.insert(data,temp)
			elseif result.data_obj=="fscx" then
				temp = tonumber(linetext:match("\\fscx([%d%.]+)"))
				table.insert(data,temp)
			elseif result.data_obj=="fscy" then
				temp = tonumber(linetext:match("\\fscy([%d%.]+)"))
				table.insert(data,temp)
			elseif result.data_obj=="frz" then
				temp = tonumber(linetext:match("\\frz([%d%.%-]+)"))
				table.insert(data,temp)
			end
			if si==1 then
				data_min,data_max = temp,temp
			else
				data_min,data_max = math.min(temp,data_min),math.max(temp,data_max)
			end
		elseif result.option=="多行文字导入" then
			if si<=#data then
				linetext = data[si]
			else
				linetext = linetext:gsub("^{}","")
				break
			end

			if si==N and #data>N then
				local time = line.end_time
				if li == #subtitle then
					for j=1,#data-N do	
						subtitle.append(line)
						local new = subtitle[li+j]
						new.start_time = time+(j-1)*5000
						new.end_time = time+j*5000
						new.text = data[N+j]
						subtitle[li+j] = new
					end
				else
					for j=1,#data-N do	
						subtitle.insert(li+j,line)
						local new = subtitle[li+j]
						new.start_time = time+(j-1)*5000
						new.end_time = time+j*5000
						new.text = data[N+j]
						subtitle[li+j] = new
					end
				end
			end
		elseif result.option=="移动!" then
			if line.comment==false then
				if result.move_pos==true then
					if linetext:match("\\move[^v]")==nil then
						local x,y = drawing_position(linetext,line,xres,yres)
						if linetext:match("\\pos")==nil then linetext=linetext:gsub("^{","{\\pos("..x..","..y..")") end
						linetext = linetext:gsub("\\pos%(([^,]*),([^%)]*)%)",function (a,b) return "\\pos("..a+result.move_x..","..b+result.move_y..")" end)
					end
				end

				if result.move_org==true then
					linetext = linetext:gsub("\\org%(([^,]*),([^%)]*)%)",function (a,b) return "\\org("..a+result.move_x..","..b+result.move_y..")" end)
				end

				if result.move_clip==true then
					if linetext:match("\\i?clip%([%d%.%- ]+,")~=nil then
						linetext = linetext:gsub("(\\i?clip)%( *([%d%.%-]+) *, *([%d%.%-]+) *, *([%d%.%-]+) *, *([%d%.%-]+) *%)",
						function (p,a,b,c,d)
							return p.."("..a+result.move_x..","..b+result.move_y..","..c+result.move_x..","..d+result.move_y..")"
						end)
					else
						-- local Yutils = require('Yutils')
						linetext = linetext:gsub("(\\i?clip)%(([^%)]*)%)",
						function (p,a)
							a = Yutils.shape.filter(a,function (x,y) return x+result.move_x,y+result.move_y end)
							return p.."("..a..")"
						end)
					end
				end

				if result.move_move==true then
					linetext = linetext:gsub("\\move%( *([%d%.%-]+) *, *([%d%.%-]+) *, *([%d%.%-]+) *, *([%d%.%-]+) *",
					function (a,b,c,d)
						return "\\move("..a+result.move_x..","..b+result.move_y..","..c+result.move_x..","..d+result.move_y
					end)
				end

				if result.move_move2==true then
					local mnum = tonumber(linetext:match("\\moves(%d)"))
					linetext = linetext:gsub("(\\moves%d)%(([^%)]*)%)",
					function (p,a)
						local i = 0
						local new_a = ""
						for x,y in a:gmatch(" *([%d%.%-]+) *, *([%d%.%-]+) *") do
							i = i + 1
							if i<=mnum then
								x,y = tonumber(x),tonumber(y)
								x,y = x+result.move_x,y+result.move_y
							end
							new_a = new_a..x..","..y..","
						end
						new_a = new_a:gsub(",$","")
						return p.."("..new_a..")"
					end)
				end
			end
		elseif result.option=="用\\N分隔双语字幕" then
			linetext = linetext:gsub("^{}","")
			linetext=linetext:gsub("([\128-\191][^ ]*) +([\1-\127]+)$","%1\\N%2")
		elseif result.option=="多行文字Shift" then
			linetext = linetext:gsub("^{}","")
			if (result.shift_b == true and result.shift_f == true) or (result.shift_b == false and result.shift_f == false) then
				aegisub.cancel()
			elseif si==1 and result.shift_b == true then
				result.shift_n = -1* result.shift_n
			end
			local nli = round(li+result.shift_n)
			local new = subtitle[nli]
			new.actor = ""
			new.actor = linetext
			subtitle[nli] = new
			linetext = ""
        elseif result.option=="双语字幕前后对调" then
			linetext = linetext:gsub("^{}","")
			if linetext:match("\\N *{[^}]*}") then
				linetext = linetext:gsub("(.*)\\N *({[^}]*})(.*)","%3\\N%2%1")
			else
				linetext = linetext:gsub("(.*)\\N(.*)","%2\\N%1")
			end
		elseif result.option=="Tag Copy" then
		-- 	linetext = linetext:gsub("^{}","")
		-- 	-- first get the template
		-- 	if si==1 then
		-- 		result.copy_template = result.copy_template:gsub("[^,]*,","",9)
		-- 		result.copy_template = result.copy_template:gsub("\\h","|")
		-- 		local temp = result.copy_template:match("^{[^}]*}[ |]*")
		-- 		temp = temp:gsub("|","\\h")
		-- 		table.insert(copy_template,temp)
		-- 		for j in result.copy_template:gmatch("[ |]*\\N[ |]*") do
		-- 			j = j:gsub("|","\\h")
		-- 			table.insert(copy_template,j)
		-- 		end
		-- 		result.copy_template = result.copy_template:gsub("^{[^}]*}[ |]*","")
		-- 		result.copy_template = result.copy_template:gsub("[ |]*\\N[ |]*","")
		-- 		for j in result.copy_template:gmatch("[ |]*{[^}]*}[ |]*") do
		-- 			j = j:gsub("|","\\h")
		-- 			table.insert(copy_template_2,j)
		-- 		end
		-- 	end
		-- 	-- then Copy
		-- 	if result.copy_head == true then
		-- 		linetext = linetext:gsub("^ *",copy_template[1])
		-- 	end

		-- 	if result.copy_N == true then
		-- 		for j=2,#copy_template do
		-- 			linetext = linetext:gsub(" *\\N *",copy_template[j],1)
		-- 		end
		-- 	end

		-- 	if result.copy_I ==true then
		-- 		for j=1,#copy_template_2 do
		-- 			linetext = linetext:gsub(" *| *",copy_template_2[j],1)
		-- 		end
		-- 	end
		else
			linetext = linetext:gsub("^{}","")
		end

        line.text=linetext
        subtitle[li]=line
		aegisub.progress.set((si-1)/N*100)
    end

	-- log output
	if result.option == "对白检查器" then
		aegisub.log(log.overlength.." overlength mistake(s),\n"..log.overlap.." overlap mistake(s),\n"..log.bilang.." bilang mistake(s) have been found!")
	-- 摩卡数据可视化
	elseif result.option == "摩卡数据可视化" then
		local data_visual,data_buttons = {},{"Read"}

		if result.data_mode=="x-t" then
			local unit = (data_max-data_min)/(visualization_max_width-1)
			-- the first line: filled with xxx
			for j = 0,visualization_max_width+1 do
				table.insert(data_visual,{class="label",label="x",x=j,y=0})
			end

			for j = 1,N do
				-- the point
				local temp = round((data[j]-data_min)/unit) + 1
				table.insert(data_visual,{class="label",label="x",x=temp+1,y=j})
				-- the number
				if result.data_num==true then
					local j1,j2 = data_index%10,math.floor((data_index%100)/10)
					table.insert(data_visual,{class="label",label=j1,x=temp,y=j})
					table.insert(data_visual,{class="label",label=j2,x=temp-1,y=j})
					data_index = data_index + 1
				end
			end

			if result.data_obj=="x" or result.data_obj=="fscx" then table.insert(data_visual,{class="label",label="X",x=visualization_max_width+2,y=0})
			elseif result.data_obj=="y" or result.data_obj=="fscy" then table.insert(data_visual,{class="label",label="Y",x=visualization_max_width+2,y=0})
			elseif result.data_obj=="frz" then table.insert(data_visual,{class="label",label="Z",x=visualization_max_width+2,y=0})
			end
			table.insert(data_visual,{class="label",label="T",x=0,y=N})
		elseif result.data_mode=="t-x" then
			local unit = (data_max-data_min)/(visualization_max_height-1)
			-- the first line: filled with xxx
			for j = 0,visualization_max_height+1 do
				table.insert(data_visual,{class="label",label="x",x=0,y=j})
			end

			for j = 1,N do
				-- the point
				local temp = round((data[j]-data_min)/unit) + 1
				table.insert(data_visual,{class="label",label="x",x=j,y=temp+1})
				-- the number
				if result.data_num==true then
					local j1,j2 = data_index%10,math.floor((data_index%100)/10)
					table.insert(data_visual,{class="label",label=j1,x=j,y=temp})
					table.insert(data_visual,{class="label",label=j2,x=j,y=temp-1})
					data_index = data_index + 1
				end
			end

			if result.data_obj=="x" or result.data_obj=="fscx" then table.insert(data_visual,{class="label",label="X",x=0,y=visualization_max_height+2})
			elseif result.data_obj=="y" or result.data_obj=="fscy" then table.insert(data_visual,{class="label",label="Y",x=0,y=visualization_max_height+2})
			elseif result.data_obj=="frz" then table.insert(data_visual,{class="label",label="Z",x=0,y=visualization_max_height+2})
			end
			table.insert(data_visual,{class="label",label="T",x=N,y=0})
		end

		local data_pressed, data_result = aegisub.dialog.display(data_visual,data_buttons)
	elseif result.option == "多行文字Shift" then
		for si,li in ipairs(selected) do
			local nli = round(li+result.shift_n)
			local new = subtitle[nli]
			new.text = new.actor
			new.actor = ""
			subtitle[nli] = new
		end
	end
	
	:: loop_end ::
    aegisub.set_undo_point(script_name) 
    return selected 
end

function drawing_position(ltext,line,xres,yres)
	local x,y,top,left,bottom,right,center,middle = 0,0,0,0,0,0,0,0
	
	local ratiox,ratioy = 1,1
	if (ltext:match("\\fs%d")~=nil) then
		ratiox = tonumber(ltext:match("\\fs([%d%.]+)")) / line.styleref.fontsize
		ratioy = tonumber(ltext:match("\\fs([%d%.]+)")) / line.styleref.fontsize
	end
	if (ltext:match("\\fscx")~=nil) then 
		ratiox = ratiox * tonumber(ltext:match("\\fscx([%d%.]+)")) / line.styleref.scale_x
	end
	if (ltext:match("\\fscy")~=nil) then 
		ratioy = ratioy * tonumber(ltext:match("\\fscy([%d%.]+)")) / line.styleref.scale_y
	end
	local width = line.width * ratiox
	local height = line.height * ratioy
	local an = ltext:match("\\an%d") and tonumber(ltext:match("\\an(%d)")) or line.styleref.align
	if     (an == 1) then
		if (ltext:match("\\pos")~=nil) then
			left = tonumber(ltext:match("\\pos%(([^,]+)"))
			bottom = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			left = line.styleref.margin_l
			bottom = yres-line.styleref.margin_b
		end
		x,y = left,bottom
		right = left + width
		top = bottom - height
	elseif (an == 2) then
		if (ltext:match("\\pos")~=nil) then
			center = tonumber(ltext:match("\\pos%(([^,]+)"))
			bottom = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			center = xres/2
			bottom = yres-line.styleref.margin_b
		end
		x,y = center,bottom
		left = center - width / 2
		right = center + width / 2
		top = bottom - height
	elseif (an == 3) then
		if (ltext:match("\\pos")~=nil) then
			right = tonumber(ltext:match("\\pos%(([^,]+)"))
			bottom = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			right = xres-line.styleref.margin_r
			bottom = yres-line.styleref.margin_b
		end
		x,y = right,bottom
		left = right - width
		top = bottom - height
	elseif (an == 4) then
		if (ltext:match("\\pos")~=nil) then
			left = tonumber(ltext:match("\\pos%(([^,]+)"))
			middle = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			left = line.styleref.margin_l
			middle = yres/2
		end
		x,y = left,middle
		right = left + width
		top = middle - height / 2
		bottom = middle + height / 2
	elseif (an == 5) then
		if (ltext:match("\\pos")~=nil) then
			center = tonumber(ltext:match("\\pos%(([^,]+)"))
			middle = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			center = xres/2
			middle = yres/2
		end
		x,y = center,middle
		left = center - width / 2
		right = center + width / 2
		top = middle - height / 2
		bottom = middle + height / 2
	elseif (an == 6) then
		if (ltext:match("\\pos")~=nil) then
			right = tonumber(ltext:match("\\pos%(([^,]+)"))
			middle = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			right = xres-line.styleref.margin_r
			middle = yres/2
		end
		x,y = right,middle
		left = right - width
		top = middle - height / 2
		bottom = middle + height / 2
	elseif (an == 7) then
		if (ltext:match("\\pos")~=nil) then
			left = tonumber(ltext:match("\\pos%(([^,]+)"))
			top = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			left = line.styleref.margin_l
			top = line.styleref.margin_t
		end
		x,y = left,top
		right = left + width
		bottom = top + height
	elseif (an == 8) then
		if (ltext:match("\\pos")~=nil) then
			center = tonumber(ltext:match("\\pos%(([^,]+)"))
			top = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			center = xres/2
			top = line.styleref.margin_t
		end
		x,y = center,top
		left = center - width / 2
		right = center + width / 2
		bottom = top + height
	elseif (an == 9) then
		if (ltext:match("\\pos")~=nil) then
			right = tonumber(ltext:match("\\pos%(([^,]+)"))
			top = tonumber(ltext:match("\\pos%([^,]+,([^%)]+)"))
		else
			right = xres-line.styleref.margin_r
			top = line.styleref.margin_t
		end
		x,y = right,top
		left = right - width
		bottom = top + height
	else
	end
	center,middle = (left+right)/2, (top+bottom)/2
	return x,y
end

function round(x)
	return math.floor(x+0.5)
end

function macro_validation(subtitle, selected, active)
    return true
end

--This is what puts your automation in Aegisub's automation list
aegisub.register_macro(script_name,script_description,main,macro_validation)