import hjson
import math

def transformMiraclegrueConfig(config: dict):
    try:  
        del config['baseLayer']
    except:
        pass   
    # the baseLayer propery is not part of the official miraclegrue config schema, but makerbot print tends to insert it anyway.    
    
    config['layerHeight'] = 0.2
    config['floorSolidThickness'] = 0.4
    config['roofSolidThickness'] = 0.4
    config['modelFillProfiles']['sparse']['density'] = 0.9
    config['doRaft'] = True
    config['doFixedShellStart'] = False
    config['doSupport'] = False
    config['modelShellProfiles']['extent']['numberOfShells'] = 3
    # config['modelShellProfiles']['base_layer_surface']['numberOfShells'] = 3


    return config


    
