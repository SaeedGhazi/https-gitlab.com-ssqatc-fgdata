#---------------------------------------------------------------------------
#
#	Title                : Frame Utils
#
#	File Type            : Implementation File
#
#	Description          : Objects related to frame processing
#
#	Author               : Richard Harrison (richard@zaretto.com)
#
#	Creation Date        : 05-05-2019
#
#	Version              : 1.0
#
#  Copyright (C) 2019 Richard Harrison           Released under GPL V2
#
#---------------------------------------------------------------------------*/


#---------------------------------------------------------------------------*/
# Partition data and process
#
#    This manages the processing of data in a manner suitable for real time
#    operations.  Given a data array [0..size] this will process a number
#    of array elements each time it is called This allows for a simple way
#    to split up intensive processing across multiple frames.
#    
#    The limit is the number of elements to process per invocation.
#    A future improvement will be to also limit the 
#    maximum amount of time to spend processing 
#
#    Usually one of more instances of this class will be contained within 
#    another object, however this will work equally well in global space.
#
# example usage (object);
# 
# var VSD_Device =
# {
#     new : func(designation, model_element, target_module_id, root_node)
#     {
# ...
#        obj.process_targets = PartitionProcessor.new("VSD-targets", 20, nil);
#        obj.process_targets.set_max_time_usec(500);
# ...
#      me.process_targets.set_timestamp(notification.Timestamp);
#
# then invoke.
#      me.process_targets.process(me, awg_9.tgts_list, 
#                                 func(pp, obj, data){
#                                     # initialisation; called before processing element[0]
#                                     # params
#                                     #  pp is the partition processor that called this
#                                     #  obj is the reference object (first argument in the .process)
#                                     #  data is the entire data array.
#                                 }
#                                 ,
#                                 func(pp, obj, element){
#                                     # proces individual element; 
#                                     # params
#                                     #  pp is the partition processor that called this
#                                     #  obj is the reference object (first argument in the .process)
#                                     #  element is the element data[pp.data_index]
#                                     # return 0 to stop processing any more elements and call the completed method
#                                     # return 1 to continue processing.
#                                 },
#                                 func(pp, obj, data)
#                                 {
#                                     # completed; called after the last element processed
#                                     # params
#                                     #  pp is the partition processor that called this
#                                     #  obj is the reference object (first argument in the .process)
#                                     #  data is the entire data array.
#                                 });

var PartitionProcessor = 
{
    new : func(_name, _size){
        var obj = {
                   parents : [PartitionProcessor],
                   data_index : 0,
                   ppos : 0,
                   name : _name,
                   end : 0,
                   partition_size : _size,
                  };
        return obj;
    },

    process : func (object, data, init_method, process_method, complete_method){

        if (me.end != size(data)) {
            # data changed during processing restart at the beginning.
            me.data_index = 0;
        }

        if (me.data_index == 0) {
            me.end = size(data);
            init_method(me, object, data);
        }

        if (me.end == 0)
          return;

        me.start_pos = me.data_index;

        for (me.ppos=0;me.ppos < me.partition_size; me.ppos  += 1) {
            if (me.data_index >= me.end) {
                complete_method(me, object, data);
                me.data_index = 0;
                return;
            }
            if (!process_method(me, object, data[me.data_index])) {
                complete_method(me, object, data);
                me.data_index = 0;
                return;         # halt processing requested.
            } else
              me.data_index += 1;

            if (me.data_index == me.start_pos) {
                complete_method(me, object, data);
                return;
            }
        }
    },
};
