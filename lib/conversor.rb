
module Conversor
   class Conversor
     
     attr_accessor :output, :svn_name
      
     def initialize(output, name)
       @output = output    
       @svn_name = name  
     end               
     
     def set_svn_origin(svn_origin)
      @svn_origin = svn_origin
     end
     
     def checkout_origin_repo()
      if(File.exist?("/tmp/"+@svn_name))
        system("rm -Rf /tmp/"+@svn_name) 
      end
      system("svn checkout "+ @svn_origin + " /tmp/"+@svn_name)
     end
     
   end
end