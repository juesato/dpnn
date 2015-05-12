local ParallelTable, parent = nn.ParallelTable, nn.Container

function ParallelTable:profile()
   function ParallelTable:updateOutput(input)
      for i=1,#self.modules do
         local start = os.clock()
         self.output[i] = self.modules[i]:updateOutput(input[i])
         if cutorch then cutorch.synchronize() end
         print(torch.type(self.modules[i])..' updateOutput: '..os.clock() - start.." s")
      end
      return self.output
   end

   function ParallelTable:updateGradInput(input, gradOutput)
      for i,module in ipairs(self.modules) do
         local start = os.clock()
         self.gradInput[i]= module:updateGradInput(input[i], gradOutput[i])
         if cutorch then cutorch.synchronize() end
         print(torch.type(module)..' updateGradInput: '..os.clock() - start.." s")
      end
      return self.gradInput
   end

   function ParallelTable:accGradParameters(input, gradOutput, scale)
      scale = scale or 1
      for i,module in ipairs(self.modules) do
         local start = os.clock()
         module:accGradParameters(input[i], gradOutput[i], scale)
         if cutorch then cutorch.synchronize() end
         print(torch.type(module)..' accGradParameters: '..os.clock() - start.." s")
      end
   end

   function ParallelTable:accUpdateGradParameters(input, gradOutput, lr)
      lr = lr or 1
      for i,module in ipairs(self.modules) do
         local start = os.clock()
         module:accUpdateGradParameters(input[i], gradOutput[i], lr)
         if cutorch then cutorch.synchronize() end
         print(torch.type(module)..' accUpdateGradParameters: '..os.clock() - start.." s")
      end
   end
   parent.profile(self)
end
