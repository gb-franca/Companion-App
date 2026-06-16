import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'campaign_model.dart';
import 'campaign_repository.dart';

class CampaignsNotifier extends AsyncNotifier<List<Campaign>> {
  late final CampaignRepository _repository;

  @override
  FutureOr<List<Campaign>> build() async {
    _repository = ref.watch(campaignRepositoryProvider);
    return _repository.getAllCampaigns();
  }

  Future<void> loadCampaigns() async {
    state = const AsyncValue<List<Campaign>>.loading();
    state = await AsyncValue.guard<List<Campaign>>(() async {
      return _repository.getAllCampaigns();
    });
  }

  Future<void> addCampaign(Campaign campaign) async {
    state = const AsyncValue<List<Campaign>>.loading();
    state = await AsyncValue.guard<List<Campaign>>(() async {
      await _repository.insertCampaign(campaign);
      return _repository.getAllCampaigns();
    });
  }

  Future<void> editCampaign(Campaign campaign) async {
    state = const AsyncValue<List<Campaign>>.loading();
    state = await AsyncValue.guard<List<Campaign>>(() async {
      await _repository.updateCampaign(campaign);
      return _repository.getAllCampaigns();
    });
  }

  Future<void> removeCampaign(int id) async {
    state = const AsyncValue<List<Campaign>>.loading();
    state = await AsyncValue.guard<List<Campaign>>(() async {
      await _repository.deleteCampaign(id);
      return _repository.getAllCampaigns();
    });
  }
}

final campaignsProvider = AsyncNotifierProvider<CampaignsNotifier, List<Campaign>>(() {
  return CampaignsNotifier();
});
