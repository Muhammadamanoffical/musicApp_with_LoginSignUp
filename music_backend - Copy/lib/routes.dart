import 'package:shelf_router/shelf_router.dart';

import 'controllers/song_controller.dart';
import 'controllers/upload_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';

Router getRouter() {
  final router = Router();

  // Auth Routes
  router.post('/signup', AuthController.signup);
  router.post('/login', AuthController.login);

  // User Routes
  router.get('/user/profile', UserController.getUserProfile);
  router.post('/user/update-profile', UserController.updateUserProfile);
  router.post('/user/update-picture', UserController.updateProfilePicture);
  router.post('/user/update-bio', UserController.updateBio);
  router.post('/user/change-password', UserController.changePassword);
  router.get('/user/favorites', UserController.getUserFavorites);
  router.post('/user/delete-account', UserController.deleteUserAccount);
  router.get('/users/all', UserController.getAllUsers);
  router.get('/users/search', UserController.searchUsers);

  // Song Routes
  router.get('/songs', SongController.getSongs);
  router.post('/add-song', SongController.addSong);


  // Upload Route
  router.post('/upload', UploadController.uploadSong);

  // Favorite Routes
  router.post('/favorite', FavoriteController.addFavorite);
 

  // Search Route
  router.get('/search', SearchController.searchSongs);

  return router;
}