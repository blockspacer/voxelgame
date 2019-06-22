extends VoxelStream

	
func emerge_block(buffer:VoxelBuffer, origin:Vector3, lod:int):
	#print("Emerging block at pos: ", origin)
	if lod != 0: return
	if origin.y < 0: buffer.fill(1, 0)	
	if origin.x==origin.z and origin.y < 1: buffer.fill(1,0)
		
	#buffer.fill_area(1, Vector3(0,0,0), Vector3(100,0)
	
	#var bsize:Vector3 = buffer.get_size()

	"""for rz in range(0,bsize.z):
		for rx in range(0, bsize.x):
			for ry in range(0, bsize.y):
				buffer.set_voxel(1, rx, ry, rz, 0)
	"""			

	"""
	var rh = 0
	if (rh > bsize.y):
		rh = bsize.y

	var ry
	for rz in range(0, bsize.z):
		for rx in range(0, bsize.x):
			ry=0
			while ry < rh:
				buffer.set_voxel(1, rx, ry, rz, 0)
				ry+=1
	"""			
	"""
	ClassDB::bind_method(D_METHOD("set_voxel", "value", "x", "y", "z", "channel"), &VoxelBuffer::_set_voxel_binding, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("set_voxel_f", "value", "x", "y", "z", "channel"), &VoxelBuffer::_set_voxel_f_binding, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("set_voxel_v", "value", "pos", "channel"), &VoxelBuffer::set_voxel_v, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("get_voxel", "x", "y", "z", "channel"), &VoxelBuffer::_get_voxel_binding, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("get_voxel_f", "x", "y", "z", "channel"), &VoxelBuffer::get_voxel_f, DEFVAL(0));

	ClassDB::bind_method(D_METHOD("fill", "value", "channel"), &VoxelBuffer::fill, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("fill_f", "value", "channel"), &VoxelBuffer::fill_f, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("fill_area", "value", "min", "max", "channel"), &VoxelBuffer::_fill_area_binding, DEFVAL(0));
	"""
