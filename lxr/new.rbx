#!/usr/bin/ruby -w
require 'mysql'

class Sched_switch
	private
	#pid
	def pid(key)
        if @flag == false
            @has['pid'] = key.hex
            @has['p_comm'] = key
        end
	end
	#tid
	def tid(key)
        if @flag == false
            @has['task'] = key.hex
            @has['t_comm'] = key
        end
	end
	#startTime
	def startTime(key)
        if @flag == false
            @has['s_time'] = key.hex/1000000000.0
        end
	end
	#endTime
	def endTime(key)
        num = key.hex/1000000000.0
        if @has['e_time'] < num
            @has['e_time'] = num
        end
	end
    def line
        lineS = []
        lineE = []
        lineS << @has['pid'].to_s + '-' + @has['task'].to_s << '[000]'
        lineS << '....' << @has['s_time'].to_s+':' << 'sched_switch:'
        lineS << 'prev_comm=a prev_pid=0 prev_prio=0 prev_state=R' << '==>'
        lineS << 'next_comm='+@has['p_comm'].to_s+'('+@has['t_comm'].to_s+')'
        lineS << 'next_pid='+@has['pid'].to_s << 'next_prio=0'
        
        lineE << @has['pid'].to_s + '-' + @has['task'].to_s << '[000]'
        lineE << '....' << @has['e_time'].to_s+':' << 'sched_switch:'
        lineE << 'prev_comm=a prev_pid=0 prev_prio=0 prev_state=R' << '==>'
        lineE << 'next_comm=a next_pid=0 next_prio=0'

        puts lineS * ' ' + '\\n\\'
        puts lineE * ' ' + '\\n\\'
    end
	public
	#初始化
	def initialize(result)
		@result = result
        @has = {}
        @flag = false
        @temID = ''
	end
	def output
        flag = false
        tem = ''
        @has['e_time'] = 0
		@result.each_hash do |row|
            #初始化tem，只需执行一次即可，初始化值为第一行
            if flag == false
                tem = row['PID'].to_s+row['TID'].to_s
                flag = true
            end
            # tem代表上一行，如果上一行和这一行不同，则说明上一行是线程的结束时间，开始处理这个线程
            # @flag用于约束只取一次某函数开始时间，此开始时间就是所在线程的开始时间
            if tem != row['PID'].to_s+row['TID'].to_s
                line
                @flag = false
                @has['e_time'] = 0
            end
			row.each do |key,value|
				case key
				when 'PID'
					pid(value)
				when 'TID'
					tid(value)
				when 'C_time'
					startTime(value)
				when 'R_time'
					endTime(value)
				end
			end
            @flag = true
            tem = row['PID'].to_s+row['TID'].to_s
		end
        if @flag == true
            line
        end
	end
end

class Tracing_mark_write
    def initialize(data,mydb)
        @data = data
        @mydb = mydb
    end
    def trans_pid(pid)
        return pid.hex
    end
    def trans_tid(tid)
        return tid.hex
    end
    def trans_ctime(ctime)
        return ctime.hex/1000000000.0
    end
    def trans_rtime(rtime)
        return rtime.hex/1000000000.0
    end
    def tout
        num= @data.num_rows()
        for i in 0..num-1
            @data.data_seek(i)
            mytest=@data.fetch_hash()
            my_pid=trans_pid(mytest['PID'])
            my_tid=trans_tid(mytest['TID'])
            my_ctime=trans_ctime(mytest['C_time'])
            my_rtime=trans_rtime(mytest['R_time'])
            if mytest['C_point'].to_i != 0
                function=@mydb.query("select * from `#{$option}_FDLIST` where f_id='#{mytest['C_point'].to_i}'")
                my_function=function.fetch_hash()  
                if ! my_function:
                    my_function = {}
                    my_function['f_name'] = 'unKnowFunc'
                end
            else
                my_function = {}
                my_function['f_name'] = 'unKnowFunc'
            end
            my_function['f_name']
            puts " Thread_"+mytest['TID']+"-"+my_tid.to_s+" [000] ...1 "+my_ctime.to_s+": tracing_mark_write: B|"+my_pid.to_s+"|"+my_function['f_name']+"\\n\\"
            puts " Thread_"+mytest['TID']+"-"+my_tid.to_s+" [000] ...1 "+my_rtime.to_s+": tracing_mark_write: E\\n\\"
        end
    end
end

start = ARGV[0]
ends = ARGV[1]
version=ARGV[2]
arch=ARGV[3]
$option=version+"_R_"+arch

if start!='' && ends !=''
    if (ends.to_i-start.to_i>0)
        limi = ends.to_i-start.to_i
        sql = start +','+limi.to_s
    else
        sql = 0.to_s
    end
else
    start = 1
    ends = 500
    sql = 500.to_s
end

mydb = Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
line = "SELECT * FROM (SELECT * FROM `#{$option}_DLIST` LIMIT "+sql+") AS MY ORDER By C_time"
res = mydb.query(line)
scd = Sched_switch.new(res)
test = Tracing_mark_write.new(res,mydb)
html_head = <<HTML_HEAD
    <div class="view">
    </div>
    <script language="javascript" type="text/javascript" src="templates/script.js">
    </script>
    <script language="javascript">
    document.addEventListener('DOMContentLoaded', function() {
      if (!linuxPerfData)
        return;

      var m = new tracing.TraceModel(linuxPerfData);
      var timelineViewEl = document.querySelector('.view');
      ui.decorate(timelineViewEl, tracing.TimelineView);
      timelineViewEl.model = m;
      timelineViewEl.tabIndex = 1;
      timelineViewEl.timeline.focusElement = timelineViewEl;
    });
    </script>
    <!-- BEGIN TRACE -->
  <script>
  var linuxPerfData = "\\
# tracer: nop\\n\\
#\\n\\
# entries-in-buffer/entries-written: 42096/42096   #P:2\\n\\
#\\n\\
#                              _-----=> irqs-off\\n\\
#                             / _----=> need-resched\\n\\
#                            | / _---=> hardirq/softirq\\n\\
#                            || / _--=> preempt-depth\\n\\
#                            ||| /     delay\\n\\
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION\\n\\
#              | |       |   ||||       |         |\\n\\
HTML_HEAD
puts html_head
scd.output
test.tout
puts html_tail = <<HTML_TAIL
\\n";
  </script>
<!-- END TRACE -->
HTML_TAIL
res.free()
mydb.close

