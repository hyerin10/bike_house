import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 사용자 정보 모델
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.initials,
  });

  final String name;
  final String email;
  final String initials;
}

/// 등록된 바이크 모델
class BikeInfo {
  const BikeInfo({
    required this.model,
    required this.year,
  });

  final String model;
  final String year;
}

/// 활동 통계 모델
class ProfileStats {
  const ProfileStats({
    required this.orderCount,
    required this.wishlistCount,
    required this.couponCount,
  });

  final int orderCount;
  final int wishlistCount;
  final int couponCount;
}

/// 마이페이지 전체 상태
class ProfileState {
  const ProfileState({
    required this.user,
    required this.bikes,
    required this.stats,
    this.isLoggedIn = true,
  });

  final UserProfile user;
  final List<BikeInfo> bikes;
  final ProfileStats stats;
  final bool isLoggedIn;

  ProfileState copyWith({
    UserProfile? user,
    List<BikeInfo>? bikes,
    ProfileStats? stats,
    bool? isLoggedIn,
  }) {
    return ProfileState(
      user: user ?? this.user,
      bikes: bikes ?? this.bikes,
      stats: stats ?? this.stats,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// 마이페이지 컨트롤러
class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState(
      user: UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        initials: 'JD',
      ),
      bikes: [
        BikeInfo(model: 'Honda CBR600RR', year: '2024'),
      ],
      stats: ProfileStats(
        orderCount: 2,
        wishlistCount: 2,
        couponCount: 2,
      ),
    );
  }

  /// 바이크 추가
  void addBike(BikeInfo bike) {
    state = state.copyWith(bikes: [...state.bikes, bike]);
  }

  /// 로그아웃
  void logout() {
    state = state.copyWith(isLoggedIn: false);
  }
}

/// 마이페이지 프로바이더
final profileProvider = NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);
