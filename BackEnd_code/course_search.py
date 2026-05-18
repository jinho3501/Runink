import osmnx as ox
import networkx as nx
from tqdm import tqdm


G = ox.load_graphml("data/서울특별시_대한민국_walk.graphml")
# G = ox.load_graphml("/home/sungil/Byte-King-rawdata/network_cache/광주_대한민국_walk.graphml")



def short_route_osm(start_point: tuple, end_point: tuple):
    """
    Calculate shortest route between two points and return coordinates and distance
    
    Parameters:
    start_point (tuple): (latitude, longitude) of start point
    end_point (tuple): (latitude, longitude) of end point
    G (nx.Graph): OSMnx graph object
    
    Returns:
    tuple: (route_coordinates, distance_in_meters)
    """
    start_lat, start_lon = start_point
    end_lat, end_lon = end_point

    start_node = ox.distance.nearest_nodes(G, start_lon, start_lat)
    end_node = ox.distance.nearest_nodes(G, end_lon, end_lat)    
    
    # Get shortest path and calculate its length
    route = nx.shortest_path(G, start_node, end_node, weight='length')
    distance = nx.shortest_path_length(G, start_node, end_node, weight='length')
    
    # Get coordinates for the route
    route_coords = []
    for node in route:
        route_coords.append((G.nodes[node]['x'], G.nodes[node]['y']))
        
    return route_coords, distance

def get_full_route(star_points: list):
    """
    Calculate full route through all points and back to start
    
    Parameters:
    star_points (list): List of (lat, lon) tuples
    G (nx.Graph): OSMnx graph object
    
    Returns:
    tuple: (full_route_coordinates, total_distance_in_meters)
    """
    full_route = []
    total_distance = 0
    
    # Calculate routes between consecutive points
    for i in tqdm(range(len(star_points)-1)):
        route_segment, segment_distance = short_route_osm(star_points[i], star_points[i+1])
        full_route.extend(route_segment)
        total_distance += segment_distance
    
    # Connect last point back to first point
    final_segment, final_distance = short_route_osm(star_points[-1], star_points[0])
    full_route.extend(final_segment)
    total_distance += final_distance
    
    return full_route, total_distance