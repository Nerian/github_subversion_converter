
module Conversor
   class Conversor
     
     attr_accessor :output, :svn_name, :svn_address_origin, :svn_address_destiny, :svn_origin_name, :svn_destiny_name
      
     def initialize(output)
       @output = output    
       @svn_origin_name = "origin"
       @svn_destiny_name = "destiny"  
     end                   
     
     def checkout_origin_repo()
      if(File.exist?("/tmp/"+@svn_origin_name))
        system("rm -Rf /tmp/"+@svn_origin_name) 
      end
      system("svn checkout "+ @svn_address_origin + " /tmp/"+@svn_origin_name)
      @output.puts "SVN Destiny Checkout complete"      
     end                                       
     
     def checkout_destiny_repo()
       if(File.exist?("/tmp/"+@svn_destiny_name))
         system("rm -Rf /tmp/"+@svn_destiny_name) 
       end
       system("svn checkout "+ @svn_address_destiny + " /tmp/"+@svn_destiny_name)
     end
     
   end
end