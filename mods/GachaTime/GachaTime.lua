-- GachaTime v3: patch every returned row, including uncached UI lookups.
local function log(s)
 local f=rawget(_G,'__localRadioLog') or print
 pcall(f,'[GACHATIME v3] '..tostring(s))
end
local lt=rawget(_G,'LTConfig')
local cfg=lt and lt.GachaConfig
if not cfg or type(cfg.LoadAt)~='function' then return 'WAIT GachaTime config' end
if rawget(_G,'__gachaTimeV3') then return 'READY GachaTime v3' end
local NEW={year=2027,month=1,day=15,hour=4,minute=0,second=0}
local function date(d)
 if type(d)~='table' then return d end
 local result={}
 for k,v in pairs(d) do result[k]=v end
 for k,v in pairs(NEW) do result[k]=v end
 return result
end
local function patch(row)
 if type(row)~='table' then return row end
 local d=row.EndTime
 if type(d)=='table' then rawset(row,'EndTime',date(d)) end
 return row
end
local meta=getmetatable(cfg)
local target=type(meta)=='table' and meta or cfg
for _,name in ipairs({'LoadAt','GetConfig'}) do
 local original=cfg[name]
 if type(original)=='function' then
  rawset(target,name,function(...) return patch(original(...)) end)
 end
end
for _,name in ipairs({'GetConfigValue','GetConfigValueByIndex'}) do
 local original=cfg[name]
 if type(original)=='function' then
  rawset(target,name,function(id,...)
   local fields={...}
   local values={original(id,...)}
   for i,field in ipairs(fields) do
    if field=='EndTime' then values[i]=date(values[i]) end
   end
   return (table.unpack or unpack)(values,1,#fields)
  end)
 end
end
local count=0
for i=0,cfg.count-1 do
 local row=cfg.LoadAt(i,true)
 if row then
  patch(row)
  local id=row.Id
  if id and type(cfg.GetConfig)=='function' then patch(cfg.GetConfig(id)) end
  local d=row.EndTime
  if d and d.year==2027 and d.month==1 and d.day==15 then count=count+1 end
 end
end
rawset(_G,'__gachaTimeV3',{count=count})
log('lookup hooks installed; checked '..count..'/'..cfg.count..' banners')
return 'READY GachaTime v3'
