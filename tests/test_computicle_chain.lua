local Computicle = require("Computicle");

-- Setup the leaf nodes to receive messages
local sink1 = Computicle:load("comp_sinkcode");
local sink2 = Computicle:load("comp_sinkcode");


-- Setup the splitter that will dispatch to the leaf nodes
local splitter = Computicle:load("comp_splittercode");

splitter.sink1 = sink1;
splitter.sink2 = sink2;


-- Setup the source, which will be originating messages
local source = Computicle:load("comp_sourcecode");
source.sink = splitter;


-- Close everything down from the outside
print("FINISH source: ", source:waitForFinish());

-- tell the splitter to quit
splitter:quit();
print("FINISH splitter:", splitter:waitForFinish());

-- tell the two sinks to quit once the splitter
-- has finished
--sink1:quit();
--sink2:quit();
print("Finish Sink 1: ", sink1:waitForFinish());
print("Finish Sink 2: ", sink2:waitForFinish());
