-- Copyright (C) GIANTS Software GmbH, Confidential, All Rights Reserved.

AIAnimCurve = {};

function AIAClinearInterpolator1(first, second, alpha)
    return (second.v + alpha*(first.v-second.v));
end;

function AIAClinearInterpolator2(first, second, alpha)
    local oneMinusAlpha = 1-alpha;
    return (first.x*alpha + second.x*oneMinusAlpha), (first.y*alpha + second.y*oneMinusAlpha);
end;

function AIAClinearInterpolator3(first, second, alpha)
    local oneMinusAlpha = 1-alpha;
    return (first.x*alpha + second.x*oneMinusAlpha), (first.y*alpha + second.y*oneMinusAlpha), (first.z*alpha + second.z*oneMinusAlpha);
end;

function AIAClinearInterpolator4(first, second, alpha)
    local oneMinusAlpha = 1-alpha;
    return (first.x*alpha + second.x*oneMinusAlpha), (first.y*alpha + second.y*oneMinusAlpha), (first.z*alpha + second.z*oneMinusAlpha), (first.w*alpha + second.w*oneMinusAlpha);
end;

function AIAClinearInterpolatorTransRotScale(first, second, alpha)
    local oneMinusAlpha = 1-alpha;
    return (first.x*alpha + second.x*oneMinusAlpha),
           (first.y*alpha + second.y*oneMinusAlpha),
           (first.z*alpha + second.z*oneMinusAlpha),

           (first.rx*alpha + second.rx*oneMinusAlpha),
           (first.ry*alpha + second.ry*oneMinusAlpha),
           (first.rz*alpha + second.rz*oneMinusAlpha),

           (first.sx*alpha + second.sx*oneMinusAlpha),
           (first.sy*alpha + second.sy*oneMinusAlpha),
           (first.sz*alpha + second.sz*oneMinusAlpha);
end;

function AIAClinearInterpolatorN(first, second, alpha)
    local oneMinusAlpha = 1-alpha;
    local ret={};
    for i=1, table.getn(first.v) do
        table.insert(ret, first.v[i]*alpha + second.v[i]*oneMinusAlpha);
    end;
    return ret;
end;

function AIACcatmullRomInterpolator1(p1, p2, p0, p3, t)

    t = 1-t;
    local t2 = t*t;
    local t3 = t2*t;

    local p0v;
    if p0 == nil then
        p0v = 2*p1.v - p2.v;
    else
        p0v = p0.v;
    end;
    local p3v;
    if p3 == nil then
        p3v = 2*p2.v - p1.v;
    else
        p3v = p3.v;
    end;

    local v = 0.5 *((2 * p1.v) + (-p0v + p2.v) * t + (2*p0v - 5*p1.v + 4*p2.v - p3v) * t2 + (-p0v + 3*p1.v - 3*p2.v + p3v) * t3);

    return v;
end;

function AIACcatmullRomInterpolator3(p1, p2, p0, p3, t)

    t = 1-t;
    local t2 = t*t;
    local t3 = t2*t;

    local p0x,p0y,p0z;
    if p0 == nil then
        p0x = 2*p1.x - p2.x;
        p0y = 2*p1.y - p2.y;
        p0z = 2*p1.z - p2.z;
    else
        p0x = p0.x;
        p0y = p0.y;
        p0z = p0.z;
    end;
    local p3x,p3y,p3z;
    if p3 == nil then
        p3x = 2*p2.x - p1.x;
        p3y = 2*p2.y - p1.y;
        p3z = 2*p2.z - p1.z;
    else
        p3x = p3.x;
        p3y = p3.y;
        p3z = p3.z;
    end;

    local x = 0.5 *((2 * p1.x) + (-p0x + p2.x) * t + (2*p0x - 5*p1.x + 4*p2.x - p3x) * t2 + (-p0x + 3*p1.x - 3*p2.x + p3x) * t3);
    local y = 0.5 *((2 * p1.y) + (-p0y + p2.y) * t + (2*p0y - 5*p1.y + 4*p2.y - p3y) * t2 + (-p0y + 3*p1.y - 3*p2.y + p3y) * t3);
    local z = 0.5 *((2 * p1.z) + (-p0z + p2.z) * t + (2*p0z - 5*p1.z + 4*p2.z - p3z) * t2 + (-p0z + 3*p1.z - 3*p2.z + p3z) * t3);

    return x,y,z;
end;

function AIACquaternionInterpolator(p1, p2, t)
    return Utils.nlerpQuaternionShortestPath(p2.x, p2.y, p2.z, p2.w, p1.x, p1.y, p1.z, p1.w, t)
end;

function AIACquaternionInterpolator2(p1, p2, p0, p3, t)
    t = 1-t;
    local w0 = (1-t)*0.6;
    local w3 = t*0.6;
    if p0 == nil then
        p0 = p1;
        w0 = 0;
    end;
    if p3 == nil then
        p3 = p2;
        w3 = 0;
    end;
    local w1 = (1-t) + w3;
    local w2 = t + w0;
    local x,y,z,w = p0.x*w0, p0.y*w0, p0.z*w0, p0.w*w0;
    x,y,z,w = Utils.quaternionMadShortestPath(x,y,z,w, p1.x, p1.y, p1.z, p1.w, w1);
    x,y,z,w = Utils.quaternionMadShortestPath(x,y,z,w, p2.x, p2.y, p2.z, p2.w, w2);
    x,y,z,w = Utils.quaternionMadShortestPath(x,y,z,w, p3.x, p3.y, p3.z, p3.w, w3);
    return Utils.quaternionNormalized(x,y,z,w);
end;

local AIAnimCurve_mt = Class(AIAnimCurve);

function AIAnimCurve:new(interpolator, interpolatorDegree)

    local instance = {};
    setmetatable(instance, AIAnimCurve_mt);

    instance.keyframes = {};
    instance.interpolator = interpolator;
    instance.interpolatorDegree = Utils.getNoNil(interpolatorDegree, 2);
    instance.currentTime = 0;
    instance.maxTime = 0;

    return instance;
end;

function AIAnimCurve:delete()
end;

function AIAnimCurve:addKeyframe(keyframe)

    local numKeys = table.getn(self.keyframes);
    if numKeys > 0 and keyframe.time < self.keyframes[numKeys].time then
        print("Error: keyframes not strictly monotonic increasing");
        return;
    end;

    table.insert(self.keyframes, keyframe);
    self.maxTime = keyframe.time;
end;

-- Note: This only works for interpolators which have a return value that can be compared
function AIAnimCurve:getMaximum()
    local numKeys = table.getn(self.keyframes);
    if numKeys == 0 then
        return 0, 0;
    elseif numKeys == 1 then
        return self:getFromKeyframes(self.keyframes[1], self.keyframes[1], 1, 1, 0), self.keyframes[1].time;
    end;

    local maxValue, maxTime = self:getFromKeyframes(self.keyframes[1], self.keyframes[2], 1, 2, 0), self.keyframes[1].time;
    for i=1, numKeys-1 do
        local value = self:getFromKeyframes(self.keyframes[i], self.keyframes[i+1], i, i+1, 1);
        if value > maxValue then
            maxValue = value;
            maxTime = self.keyframes[i+1].time;
        end
    end
    return maxValue, maxTime;
end

function AIAnimCurve:get(time)

    local numKeys = table.getn(self.keyframes);
    if numKeys == 0 then
        return;
    end;

    --local time = self.currentTime;
    local first,second=nil,nil;
    local firstI, secondI=nil,nil;
    if numKeys >= 2 and self.keyframes[1].time <= time then
        if self.maxTime > time then
            for i=2, numKeys do
                second = self.keyframes[i];
                secondI = i;
                if second.time >= time then
                    first = self.keyframes[i-1];
                    firstI = i-1;
                    break;
                end;
            end;
        else
            first = self.keyframes[numKeys];
            second = first;
            firstI = numKeys;
            secondI = numKeys;
        end;
    else
        first = self.keyframes[1];
        second = first;
    end;

    local time0 = first.time;
    local time1 = second.time;

    --print(time, " ", time0, " ", time1);


    local alpha;
    if time0 < time1 then
        alpha = (time1 - time)/(time1 - time0);
    else
        alpha = 0;
    end;

    if self.segmentTimes ~= nil then
        if firstI < numKeys then
            local segmentLow=0;
            local segmentHi=1;
            local timesOffset = (firstI-1)*(self.numTimesPerKeyframe+1)+1;
            local segmentT = time-first.time;

            segmentLow, segmentHi = self:getInterval(segmentT, self.segmentTimes, timesOffset, self.numTimesPerKeyframe+1);

            alpha = segmentLow;
            local l = self.segmentTimes[segmentHi+timesOffset]-self.segmentTimes[segmentLow+timesOffset];
            if l > 0 then
                local p = segmentT-self.segmentTimes[segmentLow+timesOffset];
                alpha = alpha + p/l;
            end;
            alpha = alpha / self.numTimesPerKeyframe;
            alpha = 1-alpha;
        end;
    end;

    return self:getFromKeyframes(first, second, firstI, secondI, alpha)
end;

function AIAnimCurve:getFromKeyframes(first, second, firstI, secondI, alpha)

    if self.interpolatorDegree == 2 then
        return self.interpolator(first, second, alpha);
    elseif self.interpolatorDegree == 3 then
        local beforeFirst = nil;
        if firstI > 1 then
            beforeFirst = self.keyframes[firstI-1];
        end;
        local afterSecond = nil;
        local numKeys = table.getn(self.keyframes);
        if secondI < numKeys then
            afterSecond = self.keyframes[secondI+1];
        end;
        return self.interpolator(first, second, beforeFirst, afterSecond, alpha);
    end;
end;


function AIAnimCurve:getInterval(time, times, timesOffset, numTimes)
    local low = 0;
    local hi = numTimes;

    while hi-low > 1 do
        local kk = math.floor((hi+low)/2);
        if times[kk+timesOffset] > time then
            hi = kk;
        else
            low = kk;
        end;
    end;
    return low, hi;
end;

function AIAnimCurve:loadCurveFromXML(xmlFile, baseKey, loadFunc)
    local i = 0
    while true do
        local key = string.format("%s.key(%d)", baseKey, i)
        if not hasXMLProperty(xmlFile, key) then
            break
        end

        local keyFrame = loadFunc(xmlFile, key)
        if keyFrame ~= nil then
            self:addKeyframe(keyFrame)
        end
        i = i + 1
    end
end

function loadInterpolator3Curve(xmlFile, key)
    local time = getXMLString(xmlFile, key.."#time")
    local values = Utils.splitString(" ", getXMLString(xmlFile, key.."#values"))
    if values ~= nil then
        return {x=Utils.evaluateFormula(values[1]), y=Utils.evaluateFormula(values[2]), z=Utils.evaluateFormula(values[3]), time=Utils.evaluateFormula(time)}
    end
    return nil
end

function loadInterpolator4Curve(xmlFile, key)
    local time = getXMLString(xmlFile, key.."#time")
    local values = Utils.splitString(" ", getXMLString(xmlFile, key.."#values"))
    if values ~= nil then
        return {x=Utils.evaluateFormula(values[1]), y=Utils.evaluateFormula(values[2]), z=Utils.evaluateFormula(values[3]), w=Utils.evaluateFormula(values[4]), time=Utils.evaluateFormula(time)}
    end
    return nil
end

function loadInterpolator1Curve(xmlFile, key)
    local time = getXMLString(xmlFile, key.."#time")
    local value = getXMLString(xmlFile, key.."#value")
    if value ~= nil then
        return {v=Utils.evaluateFormula(value), time=Utils.evaluateFormula(time)}
    end

    return nil
end