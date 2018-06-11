#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)     CMUPriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     4                         ;# number of mobilenodes
set val(rp)     DSR              ;# routing protocol
set val(x)      700                        ;# X dimension of topography
set val(y)      700                        ;# Y dimension of topography
#set val(stop)   70.0                      ;# time of simulation end
Mac/802_11 set dataRate_ 10Mb

#Global Variables
set ns_ [new Simulator]
set tracefd [open project1.tr w]
$ns_ trace-all $tracefd

set namtrace [open project1.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

#create god
create-god $val(nn)

#create channel
#set chan_1_ [new $val(chan)]

#===================================
#     Mobile node parameter setup
#===================================
$ns_ node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channelType   $val(chan) \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      OFF \
                -movementTrace ON

for {set i 0} {$i < 4} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0       ;
	set mac_($i) [$node_($i) getMac 0]
	$mac_($i) set RTSThreshold_ 2346
}

$node_(0) set X_ 200.0
$node_(0) set Y_ 360.0
$node_(0) set Z_ 0.0

#below
$node_(1) set X_ 626.949
$node_(1) set Y_ 179.537
$node_(1) set Z_ 0.0


$node_(2) set X_ 100.0
$node_(2) set Y_ 320.0
$node_(2) set Z_ 0.0


$node_(3) set X_ 560.0
$node_(3) set Y_ 360.0
$node_(3) set Z_ 0.0

#labeling
$ns_ at 0.0 "$node_(0) label AP1"
$ns_ at 0.0 "$node_(1) label MN1"
$ns_ at 0.0 "$node_(2) label MN1"
$ns_ at 0.0 "$node_(3) label AP2"

#visuals

$ns_ at 0.0 "$node_(0) add-mark m1 green circle"
$ns_ at 0.0 "$node_(1) add-mark m1 red circle"
$ns_ at 0.0 "$node_(2) add-mark m1 yellow circle"
$ns_ at 0.0 "$node_(3) add-mark m1 blue circle"

set AP_ADDR1 [$mac_(0) id]
$mac_(0) ap $AP_ADDR1
set AP_ADDR2 [$mac_([expr $val(nn) - 1]) id]
$mac_([expr $val(nn) - 1]) ap $AP_ADDR2

$mac_(1) ScanType ACTIVE
$mac_(2) ScanType ACTIVE


Application/Traffic/CBR set packetSize_ 1024
Application/Traffic/CBR set rate_ 1024kb

for {set i 1} {$i < [expr $val(nn) - 1]} {incr i} {
	set udp1($i) [new Agent/UDP]

	$ns_ attach-agent $node_($i) $udp1($i)
	set cbr1($i) [new Application/Traffic/CBR]
	$cbr1($i) attach-agent $udp1($i)
}

set null0 [new Agent/Null]
$ns_ attach-agent $node_(1) $null0
$ns_ connect $udp1(1) $null0

set null1 [new Agent/Null]
$ns_ attach-agent $node_(2) $null1
$ns_ connect $udp1(2) $null1



#transfer data from 0 t0 2
set udp2 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp2
set null9 [new Agent/LossMonitor]
$ns_ attach-agent $node_(2) $null9
$ns_ connect $udp2 $null9
$udp2 set packetSize_ 1024

set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set packetSize_ 1024
$cbr2 set rate_ 0.1Mb
$cbr2 set random_ null
$ns_ at 0.0 "$cbr2 start"
$ns_ at 6.2 "$cbr2 stop"
#transfer data from 3 to 2
set udp3 [new Agent/UDP]
$ns_ attach-agent $node_(3) $udp3
set null10 [new Agent/LossMonitor]
$ns_ attach-agent $node_(2) $null10
$ns_ connect $udp3 $null10
$udp3 set packetSize_ 1024

set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $udp3
$cbr3 set packetSize_ 1024
$cbr3 set rate_ 0.1Mb
$cbr3 set random_ null
$ns_ at 6.5 "$cbr3 start"
$ns_ at 15.0 "$cbr3 stop"

#transfer data from 3 to 1
set udp4 [new Agent/UDP]
$ns_ attach-agent $node_(3) $udp4
set null11 [new Agent/LossMonitor]
$ns_ attach-agent $node_(1) $null11
$ns_ connect $udp4 $null11
$udp4 set packetSize_ 1024

set cbr4 [new Application/Traffic/CBR]
$cbr4 attach-agent $udp4
$cbr4 set packetSize_ 1024
$cbr4 set rate_ 0.1Mb
$cbr4 set random_ null
$ns_ at 0.1 "$cbr4 start"
$ns_ at 6.4 "$cbr4 stop"

#transfer data from 0 to 1
set udp5 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp5
set null12 [new Agent/LossMonitor]
$ns_ attach-agent $node_(1) $null12
$ns_ connect $udp5 $null12
$udp5 set packetSize_ 1024

set cbr5 [new Application/Traffic/CBR]
$cbr5 attach-agent $udp5
$cbr5 set packetSize_ 1024
$cbr5 set rate_ 0.1Mb
$cbr5 set random_ null
$ns_ at 6.6 "$cbr5 start"
$ns_ at 15.0 "$cbr5 stop"

#initial positions of the nodes

for {set i 0} {$i < [expr $val(nn)]} {incr i} {
	$ns_ initial_node_pos $node_($i) 35
}

$ns_ at 0.0 "$cbr1(1) start"
$ns_ at 0.0 "$cbr1(2) start"


$ns_ at 6.0 "$node_(2) setdest 690.334 369.385 1000.0"
$ns_ at 6.5 "$node_(1) setdest 291.391 447.011 1000.0"

$ns_ at 15.0 "stop"
$ns_ at 15.0 "puts \"NS EXITING...\" ; $ns_ halt"

#initialize flag

set holdseq 0
set holdtime 0

set holdtime1 0
set holdseq1 0

set holdtime2 0
set holdseq2 0

set holdtime3 0
set holdseq3 0


proc attach-expoo-traffic { node null size burst idle rate } {
#Get an instance of the simulator
set ns_ [Simulator instance]
#Create a UDP agent and attach it to the node
set source [new Agent/UDP]
$ns_ attach-agent $node $source
#Create an Expoo traffic agent and set its configuration parameters
set traffic [new Application/Traffic/Exponential]
$traffic set packetSize_ $size
$traffic set burst_time_ $burst
$traffic set idle_time_ $idle
$traffic set rate_ $rate
# Attach traffic source to the traffic generator
$traffic attach-agent $source
#Connect the source and the sink
$ns_ connect $source $null
return $traffic
}
set null00 [new Agent/LossMonitor]
set null99 [new Agent/LossMonitor]
$ns_ attach-agent $node_(0) $null00
$ns_ attach-agent $node_(3) $null99

set source0 [attach-expoo-traffic $node_(0) $null00 1000 1s 1s 1024kb]
set source1 [attach-expoo-traffic $node_(3) $null99 1024 2s 1s 1024k]
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f8 [open zerototwo.tr w]
set f9 [open threetotwo.tr w]
set f10 [open threetoone.tr w]
set f11 [open zerotoone.tr w]
proc stop {} {
	global ns_ tracefd namtrace f0 f8 f9 f10 f11 f1
	$ns_ flush-trace
    close $tracefd
    close $namtrace
    close $f0
    close $f1
    close $f8
    close $f9
    close $f10
    close $f11
    #data delivery
    exec xgraph out0.tr out1.tr -P -geometry 800x400 -P -bg white &
    #0-2 & 3-2
    exec xgraph zerototwo.tr threetotwo.tr -geometry 800x400 -P -bg white &
	#3-1 & 0-1
	exec xgraph threetoone.tr zerotoone.tr -geometry 800x400 -P -bg white &
	exec nam project1.nam  &
	exit 0
}


 proc record {} {
global null9 f1 f0 holdseq f8 null00 null99 holdtime holdtime1 holdseq1 null10 f9 holdtime2  holdseq2 f10 null11 set holdtime3 holdseq3 f11 null12


#Get an instance of the simulator
set ns_ [Simulator instance]
#Set the time after which the procedure should be called again
set time 1.0
#How many bytes have been received by the traffic sinks?
set bw0 [$null00 set bytes_]
set bw1 [$null99 set bytes_]
set bw9 [$null9 set npkts_]
set bw8 [$null9 set lastPktTime_]
set bw10 [$null10 set lastPktTime_]
set bw11 [$null10 set npkts_]
set bw12 [$null11 set lastPktTime_]
set bw13 [$null11 set npkts_]
set bw14 [$null12 set lastPktTime_]
set bw15 [$null12 set npkts_]

#Get the current time
set now [$ns_ now]
#Calculate the bandwidth (in MBit/s) and write it to the files
puts $f0 "$now [expr $bw0/$time*8/1000000]"
puts $f1 "$now [expr $bw1/$time*8/1000000]"
#Reset the bytes_ values on the traffic sinks
$null00 set bytes_ 0
$null99 set bytes_ 0



#delay
#0-2
if { $bw9 > $holdseq } {

                puts $f8 "$now [expr ($bw8 - $holdtime)/($bw9 - $holdseq)]"

        } else {

                puts $f8 "$now [expr ($bw9 - $holdseq)]"

        }
#3-2
if { $bw11 > $holdseq1 } {

                puts $f9 "$now [expr ($bw10 - $holdtime1)/($bw11 - $holdseq1)]"

        } else {

                puts $f9 "$now [expr ($bw11 - $holdseq1)]"

        }
#3-1
if { $bw13 > $holdseq2 } {

                puts $f10 "$now [expr ($bw12 - $holdtime2)/($bw13 - $holdseq2)]"

        } else {

                puts $f10 "$now [expr ($bw13 - $holdseq2)]"

        }
#0-1
if { $bw15 > $holdseq3 } {

                puts $f11 "$now [expr ($bw14 - $holdtime3)/($bw15 - $holdseq3)]"

        } else {

                puts $f11 "$now [expr ($bw15 - $holdseq3)]"

        }

       set holdseq $bw9
       set holdtime $bw8


       #Re-schedule the procedure
$ns_ at [expr $now+$time] "record"
}
$ns_ at 0.0 "record"

$ns_ at 0.0 "$source0 start"

$ns_ at 15.0 "$source0 stop"

$ns_ at 1.0 "$source1 start"

$ns_ at 15.0 "$source1 stop"

puts "stating simulation...."
$ns_ run

